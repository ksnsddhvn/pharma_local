import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/stock_batches_table.dart';
import '../database/tables/supplier_ledgers_table.dart';

/// Handles receiving new stock (purchase from supplier).
class InventoryService {
  final AppDatabase db;
  InventoryService(this.db);

  /// Records a stock inflow for a product batch.
  /// Atomically:
  ///   1. Inserts or updates the StockBatch record.
  ///   2. Creates a CREDIT_PURCHASE ledger entry for the supplier.
  ///   3. Updates supplier outstanding balance.
  Future<void> receivePurchase({
    required int productId,
    required String batchNumber,
    required DateTime expiryDate,
    required double mrp,
    required double purchaseRate,
    required double gstPercentage,
    required int quantity,
    required int supplierId,
    required double invoiceAmount,
    String? barcode,
    String? invoiceNumber,
    String? referenceNote,
    LedgerTxType? paymentMethod,
    double? paymentAmount,
  }) async {
    await db.transaction(() async {
      // 1. Insert or update batch
      final existingBatches = await db.stockBatchesDao
          .getBatchesForProduct(productId);
      final existing = existingBatches.where(
          (b) => b.batchNumber == batchNumber && b.productId == productId);

      if (existing.isNotEmpty) {
        final b = existing.first;
        await db.stockBatchesDao.updateBatch(
          StockBatchesCompanion(
            id: Value(b.id),
            productId: Value(b.productId),
            batchNumber: Value(b.batchNumber),
            expiryDate: Value(b.expiryDate),
            mrp: Value(mrp),
            purchaseRate: Value(purchaseRate),
            gstPercentage: Value(gstPercentage),
            currentStock: Value(b.currentStock + quantity),
            barcode: Value(barcode ?? b.barcode),
          ),
        );
      } else {
        await db.stockBatchesDao.insertBatch(
          StockBatchesCompanion.insert(
            productId: productId,
            batchNumber: batchNumber,
            expiryDate: expiryDate,
            mrp: mrp,
            purchaseRate: purchaseRate,
            gstPercentage: Value(gstPercentage),
            currentStock: Value(quantity),
            barcode: Value(barcode),
            isOpeningStock: Value(false),
            supplierId: Value(supplierId),
          ),
        );
      }

      // 2. Get current supplier balance
      final supplier =
          await db.suppliersDao.getSupplierById(supplierId);
      if (supplier == null) throw Exception('Supplier not found: $supplierId');

      final newBalance = supplier.currentBalance + invoiceAmount;

      // 3. Append ledger entry
      await db.supplierLedgerDao.insertEntry(
        SupplierLedgersCompanion.insert(
          supplierId: supplierId,
          transactionType: LedgerTxType.creditPurchase,
          amount: invoiceAmount,
          balanceAfter: newBalance,
          invoiceNumber: Value(invoiceNumber),
          referenceNote: Value(referenceNote),
        ),
      );

      // 4. Record immediate payment if applicable
      var finalBalance = newBalance;
      final pAmt = paymentAmount ?? invoiceAmount;
      if (paymentMethod != null && pAmt > 0) {
        finalBalance -= pAmt;
        await db.supplierLedgerDao.insertEntry(
          SupplierLedgersCompanion.insert(
            supplierId: supplierId,
            transactionType: paymentMethod,
            amount: pAmt,
            balanceAfter: finalBalance,
            referenceNote: Value('Paid immediately on receipt'),
          ),
        );
      }

      // 5. Update supplier balance
      await db.suppliersDao.updateBalance(supplierId, finalBalance);
    });
  }
}

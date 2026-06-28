import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/supplier_ledgers_table.dart';

/// Handles all supplier financial operations.
class SupplierService {
  final AppDatabase db;
  SupplierService(this.db);

  /// Records a payment towards a supplier balance.
  /// Updates balance atomically with ledger entry.
  Future<void> recordPayment({
    required int supplierId,
    required double amount,
    required LedgerTxType type, // cashPaid | upiPaid
    String? referenceNote,
  }) async {
    await db.transaction(() async {
      final supplier =
          await db.suppliersDao.getSupplierById(supplierId);
      if (supplier == null) throw Exception('Supplier not found: $supplierId');

      // Payment reduces outstanding balance
      final newBalance = supplier.currentBalance - amount;

      await db.supplierLedgerDao.insertEntry(
        SupplierLedgersCompanion.insert(
          supplierId: supplierId,
          transactionType: type,
          amount: amount,
          balanceAfter: newBalance,
          referenceNote: Value(referenceNote),
        ),
      );

      await db.suppliersDao.updateBalance(supplierId, newBalance);
    });
  }

  /// Deletes a ledger entry and reverts the supplier's balance.
  Future<void> deleteLedgerEntry(int entryId) async {
    await db.transaction(() async {
      // Get the entry
      final entry = await (db.select(db.supplierLedgers)..where((l) => l.id.equals(entryId))).getSingleOrNull();
      if (entry == null) return;

      final supplier = await db.suppliersDao.getSupplierById(entry.supplierId);
      if (supplier == null) return;

      // Revert the balance
      double newBalance = supplier.currentBalance;
      if (entry.transactionType == LedgerTxType.creditPurchase) {
        newBalance -= entry.amount; // Revert a purchase by subtracting
      } else {
        newBalance += entry.amount; // Revert a payment by adding back
      }

      // Delete the entry
      await (db.delete(db.supplierLedgers)..where((l) => l.id.equals(entryId))).go();
      
      // Update supplier balance
      await db.suppliersDao.updateBalance(entry.supplierId, newBalance);
    });
  }
}

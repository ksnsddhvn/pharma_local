import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/sales_tables.dart';

/// One item in the shopping cart before checkout.
class CartItem {
  final int batchId;
  final int productId;
  final String productName;
  final String batchNumber;
  int quantity;
  final int maxQuantity;
  final double mrp;
  final double gstPercentage;
  double discountPercent;
  final String hsnCode;
  final String packagingUnit;
  final String productType;
  final String? alternativeName;

  CartItem({
    required this.batchId,
    required this.productId,
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.maxQuantity,
    required this.mrp,
    required this.gstPercentage,
    required this.hsnCode,
    this.discountPercent = 0.0,
    this.packagingUnit = "10's",
    this.productType = 'Tablet',
    this.alternativeName,
  });

  double get baseTotal => mrp * quantity * (1 - discountPercent / 100);
  double get gstAmount => baseTotal * (gstPercentage / 100);
  double get lineTotal => baseTotal + gstAmount;
}

class CheckoutResult {
  final int invoiceId;
  final String invoiceNumber;
  final double total;
  CheckoutResult(
      {required this.invoiceId,
      required this.invoiceNumber,
      required this.total});
}

/// Handles the POS checkout flow with full ACID guarantees.
class CheckoutService {
  final AppDatabase db;
  CheckoutService(this.db);

  /// Processes checkout atomically:
  ///   1. Validates stock availability for every cart item.
  ///   2. Deducts stock from each batch.
  ///   3. Inserts the sales invoice header + all line items.
  /// Throws if any batch has insufficient stock.
  Future<CheckoutResult> processCheckout({
    required List<CartItem> items,
    required PaymentMode paymentMode,
    required String customerName,
    required String customerMobile,
    required String customerPlace,
    required String doctorName,
    required String doctorPlace,
    required double amountPaid,
    required double creditBalanceAdded,
    String? customerNotes,
  }) async {
    if (items.isEmpty) throw Exception('Cart is empty');

    return db.transaction(() async {
      // Step 1: Validate stock for all items first
      for (final item in items) {
        final batches = await db.stockBatchesDao
            .getBatchesForProduct(item.productId);
        final batch = batches.where((b) => b.id == item.batchId);
        if (batch.isEmpty) {
          throw Exception(
              'Batch ${item.batchId} not found for ${item.productName}');
        }
        if (batch.first.currentStock < item.quantity) {
          throw Exception(
              'Insufficient stock for ${item.productName}: '
              'have ${batch.first.currentStock}, need ${item.quantity}');
        }
      }

      // Step 2: Deduct stock
      for (final item in items) {
        await db.stockBatchesDao.deductStock(item.batchId, item.quantity);
      }

      // Step 3: Build invoice
      final subtotal =
          items.fold(0.0, (s, i) => s + (i.mrp * i.quantity));
      final totalDiscount = items.fold(
          0.0,
          (s, i) =>
              s + (i.mrp * i.quantity * i.discountPercent / 100));
      final totalAmount =
          items.fold(0.0, (s, i) => s + i.lineTotal);
      final totalGst =
          items.fold(0.0, (s, i) => s + i.gstAmount);
      final invoiceNumber = _generateInvoiceNumber();

      final invoiceId = await db.salesDao.createInvoiceWithItems(
        SalesInvoicesCompanion.insert(
          invoiceNumber: invoiceNumber,
          customerName: customerName,
          customerMobile: customerMobile,
          customerPlace: Value(customerPlace),
          doctorName: Value(doctorName),
          doctorPlace: Value(doctorPlace),
          subtotal: subtotal,
          totalGst: totalGst,
          totalDiscount: Value(totalDiscount),
          totalAmount: totalAmount,
          amountPaid: Value(amountPaid),
          creditBalanceAdded: Value(creditBalanceAdded),
          customerNotes: Value(customerNotes),
          paymentMode: Value(paymentMode),
        ),
        items
            .map(
              (i) => SalesInvoiceItemsCompanion.insert(
                invoiceId: 0, // replaced in DAO
                batchId: i.batchId,
                productId: i.productId,
                productName: i.productName,
                packagingUnit: Value(i.packagingUnit),
                batchNumber: i.batchNumber,
                totalTabletsSold: Value(i.quantity),
                mrpPerTablet: Value(i.mrp),
                gstPercentage: i.gstPercentage,
                discountPercent: Value(i.discountPercent),
                lineTotal: i.lineTotal,
              ),
            )
            .toList(),
      );

      return CheckoutResult(
        invoiceId: invoiceId,
        invoiceNumber: invoiceNumber,
        total: totalAmount,
      );
    });
  }

  /// Cancels an existing sale, reverts stock, and deletes the invoice.
  Future<void> cancelSale(int invoiceId) async {
    await db.transaction(() async {
      // 1. Get the items
      final items = await (db.select(db.salesInvoiceItems)
            ..where((i) => i.invoiceId.equals(invoiceId)))
          .get();
      
      // 2. Revert the stock for each item
      for (final item in items) {
        await db.stockBatchesDao.addStock(item.batchId, item.totalTabletsSold);
      }

      // 3. Delete the invoice (items will be deleted automatically if CASCADE is on,
      // but let's explicitly delete them to be safe)
      await (db.delete(db.salesInvoiceItems)..where((i) => i.invoiceId.equals(invoiceId))).go();
      await (db.delete(db.salesInvoices)..where((i) => i.id.equals(invoiceId))).go();
    });
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch % 100000;
    return 'PL-${now.year}-${ts.toString().padLeft(5, '0')}';
  }
}

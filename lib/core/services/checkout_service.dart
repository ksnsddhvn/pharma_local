import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/products_table.dart';
import '../database/tables/sales_tables.dart';

/// One item in the shopping cart before checkout.
class CartItem {
  final int batchId;
  final int productId;
  final String productName;
  final String batchNumber;
  int quantity;
  final double mrp;
  final double gstPercentage;
  double discountPercent;
  final String composition;
  final String? alternativeName;

  CartItem({
    required this.batchId,
    required this.productId,
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.gstPercentage,
    this.discountPercent = 0.0,
    this.composition = '',
    this.alternativeName,
  });

  double get lineTotal => mrp * quantity * (1 - discountPercent / 100);
  double get gstAmount =>
      lineTotal * gstPercentage / (100 + gstPercentage);
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
          doctorName: doctorName,
          doctorPlace: doctorPlace,
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
                batchNumber: i.batchNumber,
                totalTabletsSold: i.quantity,
                mrpPerTablet: i.mrp,
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

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch % 100000;
    return 'PL-${now.year}-${ts.toString().padLeft(5, '0')}';
  }
}

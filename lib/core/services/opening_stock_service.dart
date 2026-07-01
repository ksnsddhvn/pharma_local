import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/daos/stock_batches_dao.dart';

/// Handles opening stock entry for brownfield pharmacy migration.
/// Bypasses supplier/invoice requirements — only minimum fields needed.
class OpeningStockService {
  final AppDatabase db;
  OpeningStockService(this.db);

  /// Adds opening stock for an existing product.
  /// Only requires: product, batch, expiry, MRP, shelf count.
  /// Sets purchase_rate = 0, gst = 0, is_opening_stock = true.
  Future<int> addOpeningStock({
    required int productId,
    required String batchNumber,
    required DateTime expiryDate,
    required double mrp,
    required int quantity,
    String? barcode,
    double gstPercentage = 0.0,
  }) async {
    if (quantity <= 0) throw Exception('Quantity must be positive');

    return db.stockBatchesDao.insertOpeningStock(
      productId: productId,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      mrp: mrp,
      quantity: quantity,
      barcode: barcode,
      gstPercentage: gstPercentage,
    );
  }

  /// "20-Second On-the-Fly Entry" — creates the product AND its opening
  /// stock batch in a single atomic transaction. Used at the checkout
  /// counter when a scanned medicine isn't in the database yet.
  /// Returns the created BatchWithProduct for immediate cart insertion.
  Future<BatchWithProduct> quickCreateAndAdd({
    required String name,
    required String batchNumber,
    required DateTime expiryDate,
    required double mrp,
    required int quantity,
    String hsnCode = '0000',
    String? barcode,
    double gstPercentage = 0.0,
    String packagingUnit = "10's",
  }) async {
    return db.transaction(() async {
      // 1. Create the product record
      final productId = await db.productsDao.insertProduct(
        ProductsCompanion.insert(
          name: name,
          hsnCode: hsnCode,
          packagingUnit: Value(packagingUnit),
          categoryId: Value(null),
        ),
      );

      // 2. Create the opening stock batch
      final batchId = await db.stockBatchesDao.insertOpeningStock(
        productId: productId,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        mrp: mrp,
        quantity: quantity,
        barcode: barcode,
        gstPercentage: gstPercentage,
      );

      // 3. Fetch the full records for the caller
      final product = await db.productsDao.getProductById(productId);
      final batch = await (db.select(db.stockBatches)
            ..where((b) => b.id.equals(batchId)))
          .getSingle();

      return BatchWithProduct(batch: batch, product: product!);
    });
  }
}

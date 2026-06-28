import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stock_batches_table.dart';
import '../tables/products_table.dart';

part 'stock_batches_dao.g.dart';

/// Joined result for product+batch queries.
class BatchWithProduct {
  final StockBatch batch;
  final Product product;
  BatchWithProduct({required this.batch, required this.product});
}

@DriftAccessor(tables: [StockBatches, Products])
class StockBatchesDao extends DatabaseAccessor<AppDatabase>
    with _$StockBatchesDaoMixin {
  StockBatchesDao(super.db);

  /// All batches for a product, sorted by nearest expiry first (FEFO).
  Future<List<StockBatch>> getLowStockBatches(int threshold) {
    return (select(stockBatches)
          ..where((b) => 
              b.currentStock.isSmallerOrEqualValue(threshold) & 
              b.isDeleted.equals(false)))
        .get();
  }

  Future<void> deleteBatch(int batchId) async {
    await (update(stockBatches)..where((b) => b.id.equals(batchId)))
        .write(StockBatchesCompanion(isDeleted: const Value(true)));
  }

  Future<List<StockBatch>> getBatchesForProduct(int productId) =>
      (select(stockBatches)
            ..where((b) =>
                b.productId.equals(productId) & 
                b.currentStock.isBiggerThanValue(0) &
                b.isDeleted.equals(false))
            ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
          .get();

  Stream<List<StockBatch>> watchBatchesForProduct(int productId) =>
      (select(stockBatches)
            ..where((b) => b.productId.equals(productId) & b.isDeleted.equals(false))
            ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
          .watch();

  /// Returns nearest-expiry batch with stock for a given barcode.
  Future<BatchWithProduct?> findByBarcode(String barcode) async {
    final batch = await (select(stockBatches)
          ..where(
              (b) => b.barcode.equals(barcode) & 
                     b.currentStock.isBiggerThanValue(0) & 
                     b.isDeleted.equals(false))
          ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)])
          ..limit(1))
        .getSingleOrNull();

    if (batch == null) return null;

    final product = await (select(products)
          ..where((p) => p.id.equals(batch.productId)))
        .getSingleOrNull();

    if (product == null) return null;
    return BatchWithProduct(batch: batch, product: product);
  }

  Future<int> insertBatch(StockBatchesCompanion entry) =>
      into(stockBatches).insert(entry);

  /// FEFO (First Expiry First Out) deduction — called within a transaction.
  Future<void> deductStock(int batchId, int qty) async {
    final batch = await (select(stockBatches)
          ..where((b) => b.id.equals(batchId)))
        .getSingle();

    final newStock = batch.currentStock - qty;
    if (newStock < 0) {
      throw Exception(
          'Insufficient stock for batch $batchId (have ${batch.currentStock}, need $qty)');
    }

    await (update(stockBatches)..where((b) => b.id.equals(batchId)))
        .write(StockBatchesCompanion(currentStock: Value(newStock)));
  }

  /// Add stock back (used when cancelling a sale).
  Future<void> addStock(int batchId, int qty) async {
    final batch = await (select(stockBatches)
          ..where((b) => b.id.equals(batchId)))
        .getSingle();
    final newStock = batch.currentStock + qty;
    await (update(stockBatches)..where((b) => b.id.equals(batchId)))
        .write(StockBatchesCompanion(currentStock: Value(newStock)));
  }

  /// Batches expiring within [days] days.
  Future<List<BatchWithProduct>> getExpiringBatches(int days) async {
    final cutoff = DateTime.now().add(Duration(days: days));
    final rows = await (select(stockBatches)
          ..where((b) =>
              b.expiryDate.isSmallerThanValue(cutoff) &
              b.currentStock.isBiggerThanValue(0))
          ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
        .get();

    final result = <BatchWithProduct>[];
    for (final b in rows) {
      final p = await (select(products)
            ..where((pr) => pr.id.equals(b.productId)))
          .getSingleOrNull();
      if (p != null) result.add(BatchWithProduct(batch: b, product: p));
    }
    return result;
  }

  Stream<List<BatchWithProduct>> watchExpiringBatches(int days) {
    final cutoff = DateTime.now().add(Duration(days: days));
    final query = select(stockBatches).join([
      innerJoin(products, products.id.equalsExp(stockBatches.productId))
    ])
      ..where(stockBatches.expiryDate.isSmallerThanValue(cutoff) &
          stockBatches.currentStock.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.asc(stockBatches.expiryDate)]);

    return query.watch().map((rows) => rows
        .map((row) => BatchWithProduct(
              batch: row.readTable(stockBatches),
              product: row.readTable(products),
            ))
        .toList());
  }

  /// Aggregate stock level per product (for shortbook).
  Future<Map<int, int>> getTotalStockPerProduct() async {
    final rows = await select(stockBatches).get();
    final map = <int, int>{};
    for (final r in rows) {
      map[r.productId] = (map[r.productId] ?? 0) + r.currentStock;
    }
    return map;
  }

  /// Insert a batch marked as opening stock (legacy shelf item).
  /// Bypasses purchase rate / GST — only requires product, batch, expiry, MRP, qty.
  Future<int> insertOpeningStock({
    required int productId,
    required String batchNumber,
    required DateTime expiryDate,
    required double mrp,
    required int quantity,
    String? barcode,
    double gstPercentage = 0.0,
  }) =>
      into(stockBatches).insert(
        StockBatchesCompanion.insert(
          productId: productId,
          batchNumber: batchNumber,
          expiryDate: expiryDate,
          mrp: mrp,
          purchaseRate: 0.0,
          gstPercentage: Value(gstPercentage),
          currentStock: Value(quantity),
          barcode: Value(barcode),
          isOpeningStock: Value(true),
        ),
      );

  /// Watch all batches flagged as opening stock (for audit / review).
  Stream<List<BatchWithProduct>> watchOpeningStockBatches() {
    final query = select(stockBatches).join([
      innerJoin(products, products.id.equalsExp(stockBatches.productId)),
    ])
      ..where(stockBatches.isOpeningStock.equals(true))
      ..orderBy([OrderingTerm.asc(products.name)]);

    return query.watch().map((rows) => rows
        .map((row) => BatchWithProduct(
              batch: row.readTable(stockBatches),
              product: row.readTable(products),
            ))
        .toList());
  }

  Future<bool> updateBatch(StockBatchesCompanion entry) =>
      update(stockBatches).replace(entry);
}

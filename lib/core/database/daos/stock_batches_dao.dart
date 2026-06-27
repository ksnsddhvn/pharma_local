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
  Future<List<StockBatch>> getBatchesForProduct(int productId) =>
      (select(stockBatches)
            ..where((b) =>
                b.productId.equals(productId) & b.currentStock.isBiggerThanValue(0))
            ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
          .get();

  Stream<List<StockBatch>> watchBatchesForProduct(int productId) =>
      (select(stockBatches)
            ..where((b) => b.productId.equals(productId))
            ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
          .watch();

  /// Returns nearest-expiry batch with stock for a given barcode.
  Future<BatchWithProduct?> findByBarcode(String barcode) async {
    final batch = await (select(stockBatches)
          ..where(
              (b) => b.barcode.equals(barcode) & b.currentStock.isBiggerThanValue(0))
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

  /// Aggregate stock level per product (for shortbook).
  Future<Map<int, int>> getTotalStockPerProduct() async {
    final rows = await select(stockBatches).get();
    final map = <int, int>{};
    for (final r in rows) {
      map[r.productId] = (map[r.productId] ?? 0) + r.currentStock;
    }
    return map;
  }

  Future<bool> updateBatch(StockBatchesCompanion entry) =>
      update(stockBatches).replace(entry);
}

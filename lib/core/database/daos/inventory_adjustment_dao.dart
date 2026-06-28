import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/inventory_adjustments_table.dart';
import '../tables/stock_batches_table.dart';
import '../tables/products_table.dart';

part 'inventory_adjustment_dao.g.dart';

@DriftAccessor(tables: [InventoryAdjustments, StockBatches, Products])
class InventoryAdjustmentDao extends DatabaseAccessor<AppDatabase> with _$InventoryAdjustmentDaoMixin {
  InventoryAdjustmentDao(AppDatabase db) : super(db);

  /// Process an expired stock return or disposal.
  /// Deducts the stock from the batch and logs the action atomically.
  Future<void> processAdjustment({
    required int batchId,
    required int quantity,
    required AdjustmentType type,
    String? notes,
  }) async {
    await transaction(() async {
      final batch = await (select(stockBatches)..where((b) => b.id.equals(batchId))).getSingle();
      
      // 1. Deduct stock
      final newStock = batch.currentStock - quantity;
      if (newStock < 0) {
        throw Exception('Insufficient stock to adjust. Have ${batch.currentStock}, requested $quantity.');
      }
      await (update(stockBatches)..where((b) => b.id.equals(batchId))).write(
        StockBatchesCompanion(currentStock: Value(newStock)),
      );

      // 2. Log adjustment
      await into(inventoryAdjustments).insert(
        InventoryAdjustmentsCompanion.insert(
          batchId: batchId,
          productId: batch.productId,
          quantityAdjusted: quantity,
          adjustmentType: type,
          notes: Value(notes),
        ),
      );
    });
  }
}

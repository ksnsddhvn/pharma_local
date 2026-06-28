import 'package:drift/drift.dart';
import 'products_table.dart';
import 'stock_batches_table.dart';

enum AdjustmentType {
  expiredReturned,
  expiredDisposed,
  damaged,
  correction,
  other
}

@DataClassName('InventoryAdjustment')
class InventoryAdjustments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer().references(StockBatches, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantityAdjusted => integer()();
  IntColumn get adjustmentType => intEnum<AdjustmentType>()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

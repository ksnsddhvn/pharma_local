import 'package:drift/drift.dart';
import 'products_table.dart';

/// Tracks individual medicine batches with expiry, pricing and current stock.
@DataClassName('StockBatch')
class StockBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get batchNumber => text()();
  DateTimeColumn get expiryDate => dateTime()(); // indexed via DB index
  RealColumn get mrp => real()();
  RealColumn get purchaseRate => real()();
  RealColumn get gstPercentage =>
      real().withDefault(Constant(12.0))(); // 5.0 | 12.0 | 18.0
  IntColumn get currentStock =>
      integer().withDefault(Constant(0))();
  TextColumn get barcode => text().nullable()(); // optional EAN/UPC barcode
  BoolColumn get isOpeningStock =>
      boolean().withDefault(Constant(false))(); // TRUE = legacy shelf stock
}

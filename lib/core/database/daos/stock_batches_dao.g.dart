// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_batches_dao.dart';

// ignore_for_file: type=lint
mixin _$StockBatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductsTable get products => attachedDatabase.products;
  $StockBatchesTable get stockBatches => attachedDatabase.stockBatches;
  StockBatchesDaoManager get managers => StockBatchesDaoManager(this);
}

class StockBatchesDaoManager {
  final _$StockBatchesDaoMixin _db;
  StockBatchesDaoManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$StockBatchesTableTableManager get stockBatches =>
      $$StockBatchesTableTableManager(_db.attachedDatabase, _db.stockBatches);
}

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/suppliers_table.dart';
import '../tables/products_table.dart';
import '../tables/stock_batches_table.dart';

part 'suppliers_dao.g.dart';

@DriftAccessor(tables: [Suppliers, Products, StockBatches])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  Stream<List<Supplier>> watchAllSuppliers() =>
      (select(suppliers)..where((s) => s.isDeleted.equals(false))..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  Future<List<Supplier>> getAllSuppliers() =>
      (select(suppliers)..where((s) => s.isDeleted.equals(false))..orderBy([(s) => OrderingTerm.asc(s.name)])).get();

  Future<Supplier?> getSupplierById(int id) =>
      (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();

  Stream<Supplier?> watchSupplierById(int id) =>
      (select(suppliers)..where((s) => s.id.equals(id))).watchSingleOrNull();

  Future<int> insertSupplier(SuppliersCompanion entry) =>
      into(suppliers).insert(entry);

  Future<bool> updateSupplier(SuppliersCompanion entry) =>
      update(suppliers).replace(entry);

  /// Atomically update the outstanding balance after a ledger entry.
  Future<void> updateBalance(int supplierId, double newBalance) =>
      (update(suppliers)..where((s) => s.id.equals(supplierId)))
          .write(SuppliersCompanion(currentBalance: Value(newBalance)));

  Future<int> deleteSupplier(int id) =>
      (update(suppliers)..where((s) => s.id.equals(id))).write(SuppliersCompanion(isDeleted: Value(true)));

  Stream<List<SupplierProductItem>> watchPurchasedProductsForSupplier(int supplierId) {
    final query = select(products).join([
      innerJoin(stockBatches, stockBatches.productId.equalsExp(products.id)),
    ])
      ..where(stockBatches.supplierId.equals(supplierId))
      ..where(stockBatches.isOpeningStock.equals(false))
      ..orderBy([OrderingTerm.desc(stockBatches.createdAt)]);
    
    return query.watch().map((rows) {
      return rows.map((row) {
        return SupplierProductItem(
          product: row.readTable(products),
          batch: row.readTable(stockBatches),
        );
      }).toList();
    });
  }
}

class SupplierProductItem {
  final Product product;
  final StockBatch batch;
  SupplierProductItem({required this.product, required this.batch});
}

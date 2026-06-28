import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
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
}

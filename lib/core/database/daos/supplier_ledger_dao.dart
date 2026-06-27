import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/supplier_ledgers_table.dart';

part 'supplier_ledger_dao.g.dart';

@DriftAccessor(tables: [SupplierLedgers])
class SupplierLedgerDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierLedgerDaoMixin {
  SupplierLedgerDao(super.db);

  Stream<List<SupplierLedger>> watchLedgerForSupplier(int supplierId) =>
      (select(supplierLedgers)
            ..where((l) => l.supplierId.equals(supplierId))
            ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
          .watch();

  Future<List<SupplierLedger>> getLedgerForSupplier(int supplierId) =>
      (select(supplierLedgers)
            ..where((l) => l.supplierId.equals(supplierId))
            ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
          .get();

  Future<int> insertEntry(SupplierLedgersCompanion entry) =>
      into(supplierLedgers).insert(entry);
}

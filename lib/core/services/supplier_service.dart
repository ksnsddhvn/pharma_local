import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/supplier_ledgers_table.dart';

/// Handles all supplier financial operations.
class SupplierService {
  final AppDatabase db;
  SupplierService(this.db);

  /// Records a payment towards a supplier balance.
  /// Updates balance atomically with ledger entry.
  Future<void> recordPayment({
    required int supplierId,
    required double amount,
    required LedgerTxType type, // cashPaid | upiPaid
    String? referenceNote,
  }) async {
    await db.transaction(() async {
      final supplier =
          await db.suppliersDao.getSupplierById(supplierId);
      if (supplier == null) throw Exception('Supplier not found: $supplierId');

      // Payment reduces outstanding balance
      final newBalance = supplier.currentBalance - amount;

      await db.supplierLedgerDao.insertEntry(
        SupplierLedgersCompanion.insert(
          supplierId: supplierId,
          transactionType: type,
          amount: amount,
          balanceAfter: newBalance,
          referenceNote: Value(referenceNote),
        ),
      );

      await db.suppliersDao.updateBalance(supplierId, newBalance);
    });
  }
}

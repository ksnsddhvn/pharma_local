import 'package:drift/drift.dart';
import 'suppliers_table.dart';

/// Ledger transaction types for supplier account.
enum LedgerTxType { creditPurchase, cashPaid, upiPaid, creditNote }

/// Append-only audit ledger for all supplier financial transactions.
@DataClassName('SupplierLedger')
class SupplierLedgers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplierId => integer().references(Suppliers, #id)();
  TextColumn get transactionType =>
      textEnum<LedgerTxType>()(); // CREDIT_PURCHASE | CASH_PAID | UPI_PAID
  RealColumn get amount => real()();
  RealColumn get balanceAfter =>
      real()(); // running balance snapshot after this tx
  TextColumn get referenceNote =>
      text().nullable()(); // invoice / UTR / note
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
}

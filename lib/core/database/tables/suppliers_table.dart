import 'package:drift/drift.dart';

/// Distributor / supplier directory with credit balance tracker.
@DataClassName('Supplier')
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get contactPerson => text().nullable()(); // contact name at agency
  TextColumn get phone => text().nullable()();
  TextColumn get gstinNumber => text().nullable()(); // supplier GSTIN
  TextColumn get address => text().nullable()();
  RealColumn get currentBalance =>
      real().withDefault(const Constant(0.0))(); // positive = we owe them
}

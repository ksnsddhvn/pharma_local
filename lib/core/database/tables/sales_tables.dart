import 'package:drift/drift.dart';

/// Payment mode for a sales invoice.
enum PaymentMode { cash, upi, credit, card }

/// Header record for every customer checkout.
@DataClassName('SalesInvoice')
class SalesInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text()(); // e.g. "PL-2025-0001"
  TextColumn get customerName => text()();
  TextColumn get customerMobile => text()();
  TextColumn get doctorName => text().withDefault(const Constant(''))();
  TextColumn get doctorPlace => text().withDefault(const Constant(''))(); // Clinic/Hospital locality tracking
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get subtotal => real()(); // before GST
  RealColumn get totalGst => real()();
  RealColumn get totalDiscount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()(); // final billed amount
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))(); // Tracks partial clearings
  RealColumn get creditBalanceAdded => real().withDefault(const Constant(0.0))(); // Outstanding debt logged from this bill
  TextColumn get customerNotes => text().nullable()(); // Custom follow-up payment text reminders
  TextColumn get paymentMode =>
      textEnum<PaymentMode>().withDefault(const Constant('cash'))();
}

/// Line items for each invoice — one row per batch sold.
@DataClassName('SalesInvoiceItem')
class SalesInvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(SalesInvoices, #id, onDelete: KeyAction.cascade)();
  IntColumn get batchId => integer()(); // batch id (denormalised — batch may be updated)
  IntColumn get productId => integer()(); // denormalised
  TextColumn get productName => text()(); // denormalised for receipts
  TextColumn get batchNumber => text()(); // denormalised for receipts
  IntColumn get totalTabletsSold => integer().withDefault(const Constant(1))(); // Tracks individual pill counts cut from strips
  RealColumn get mrpPerTablet => real().withDefault(const Constant(0.0))();
  RealColumn get gstPercentage => real()();
  RealColumn get discountPercent => real().withDefault(const Constant(0.0))();
  RealColumn get lineTotal => real()(); // qty * mrp * (1 - discount)
}

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sales_tables.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesInvoices, SalesInvoiceItems])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  Stream<List<SalesInvoice>> watchRecentInvoices({int limit = 50}) =>
      (select(salesInvoices)
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
            ..limit(limit))
          .watch();

  Future<List<SalesInvoice>> getInvoicesForDateRange(
      DateTime from, DateTime to) =>
      (select(salesInvoices)
            ..where(
                (i) => i.createdAt.isBetweenValues(from, to))
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .get();

  Future<SalesInvoice?> getInvoiceById(int id) =>
      (select(salesInvoices)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<List<SalesInvoiceItem>> getItemsForInvoice(int invoiceId) =>
      (select(salesInvoiceItems)
            ..where((item) => item.invoiceId.equals(invoiceId)))
          .get();

  /// Atomically inserts an invoice header + all its line items.
  Future<int> createInvoiceWithItems(
    SalesInvoicesCompanion header,
    List<SalesInvoiceItemsCompanion> items,
  ) async {
    return db.transaction(() async {
      final invoiceId = await into(salesInvoices).insert(header);
      for (final item in items) {
        await into(salesInvoiceItems)
            .insert(item.copyWith(invoiceId: Value(invoiceId)));
      }
      return invoiceId;
    });
  }

  /// Settles an outstanding invoice.
  Future<void> settleInvoice(int invoiceId) async {
    final invoice = await getInvoiceById(invoiceId);
    if (invoice == null || invoice.creditBalanceAdded <= 0) return;

    await (update(salesInvoices)..where((i) => i.id.equals(invoiceId))).write(
      SalesInvoicesCompanion(
        amountPaid: Value(invoice.totalAmount),
        creditBalanceAdded: const Value(0.0),
        paymentMode: const Value(PaymentMode.cash),
      ),
    );
  }

  /// Daily sales totals for dashboard chart.
  Future<Map<DateTime, double>> getDailySalesTotals(int days) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final invoices = await getInvoicesForDateRange(from, DateTime.now());
    final map = <DateTime, double>{};
    for (final inv in invoices) {
      final day = DateTime(
          inv.createdAt.year, inv.createdAt.month, inv.createdAt.day);
      map[day] = (map[day] ?? 0.0) + inv.totalAmount;
    }
    return map;
  }

  /// Today's total sales amount.
  Future<double> getTodaysSalesTotal() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final invoices =
        await getInvoicesForDateRange(startOfDay, endOfDay);
    return invoices.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount);
  }
}

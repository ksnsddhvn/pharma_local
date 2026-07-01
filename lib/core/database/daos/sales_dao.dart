import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sales_tables.dart';
import '../tables/stock_batches_table.dart';
import '../tables/products_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesInvoices, SalesInvoiceItems, StockBatches, Products])
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
        creditBalanceAdded: Value(0.0),
        paymentMode: Value(PaymentMode.cash),
      ),
    );
  }

  Stream<List<SalesInvoice>> watchInvoicesForDateRange(DateTime start, DateTime end) =>
      (select(salesInvoices)..where((i) => i.createdAt.isBetweenValues(start, end))).watch();

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

  Stream<Map<DateTime, double>> watchDailySalesTotals(int days) {
    final from = DateTime.now().subtract(Duration(days: days));
    return watchInvoicesForDateRange(from, DateTime.now()).map((invoices) {
      final map = <DateTime, double>{};
      for (final inv in invoices) {
        final day = DateTime(inv.createdAt.year, inv.createdAt.month, inv.createdAt.day);
        map[day] = (map[day] ?? 0.0) + inv.totalAmount;
      }
      return map;
    });
  }

  /// Today's total sales amount.
  Future<double> getTodaysSalesTotal() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    final invoices =
        await getInvoicesForDateRange(startOfDay, endOfDay);
    return invoices.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount);
  }

  Stream<double> watchTodaysSalesTotal() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    return watchInvoicesForDateRange(startOfDay, endOfDay)
        .map((invoices) => invoices.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount));
  }

  Stream<double> watchOverallDebt() {
    return select(salesInvoices).watch().map((invoices) {
      return invoices.fold<double>(0.0, (sum, inv) => sum + inv.creditBalanceAdded);
    });
  }

  Stream<double> watchMonthlyRevenue() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    final endOfMonth = DateTime(nextYear, nextMonth, 1);
    
    return watchInvoicesForDateRange(startOfMonth, endOfMonth)
        .map((invoices) => invoices.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount));
  }

  Stream<CashFlowStats> watchTodaysCashFlow() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    return watchInvoicesForDateRange(startOfDay, endOfDay).map((invoices) {
      double cashUpi = 0;
      double credit = 0;
      for (final inv in invoices) {
         if (inv.paymentMode == PaymentMode.cash || inv.paymentMode == PaymentMode.upi) {
            cashUpi += inv.amountPaid;
         }
         credit += inv.creditBalanceAdded;
      }
      return CashFlowStats(cashUpi, credit);
    });
  }

  /// Breakdown of sales by payment mode over the last N days
  Future<Map<String, double>> getPaymentModeBreakdown(int days) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final invoices = await getInvoicesForDateRange(from, DateTime.now());
    final map = <String, double>{};
    for (final inv in invoices) {
      final mode = inv.paymentMode.name;
      map[mode] = (map[mode] ?? 0.0) + inv.totalAmount;
    }
    return map;
  }

  Stream<Map<String, double>> watchPaymentModeBreakdown(int days) {
    final from = DateTime.now().subtract(Duration(days: days));
    return watchInvoicesForDateRange(from, DateTime.now()).map((invoices) {
      final map = <String, double>{};
      for (final inv in invoices) {
        final mode = inv.paymentMode.name;
        map[mode] = (map[mode] ?? 0.0) + inv.totalAmount;
      }
      return map;
    });
  }

  Stream<ProfitLossStats> watchProfitLossStats(DateTime from, DateTime to) {
    return select(salesInvoices).watch().asyncMap((_) async {
      return await getProfitLossStats(from, to);
    });
  }

  /// Calculates exact Profit and Loss for a given date range
  Future<ProfitLossStats> getProfitLossStats(DateTime from, DateTime to) async {
    final invoices = await getInvoicesForDateRange(from, to);
    final invoiceIds = invoices.map((i) => i.id).toList();

    if (invoiceIds.isEmpty) {
      return ProfitLossStats(0, 0, 0, []);
    }

    final query = select(salesInvoiceItems).join([
      innerJoin(stockBatches, stockBatches.id.equalsExp(salesInvoiceItems.batchId)),
      innerJoin(products, products.id.equalsExp(salesInvoiceItems.productId)),
    ])..where(salesInvoiceItems.invoiceId.isIn(invoiceIds));

    final rows = await query.get();

    double totalRevenue = 0.0;
    double totalCogs = 0.0;
    List<LossItem> lossMakers = [];

    for (final row in rows) {
      final item = row.readTable(salesInvoiceItems);
      final batch = row.readTable(stockBatches);
      final product = row.readTable(products);

      int perStrip = 1;
      final unitStr = product.packagingUnit.toLowerCase();
      if (unitStr.endsWith("'s") || unitStr.endsWith("s")) {
        final numStr = unitStr.replaceAll(RegExp(r"[^0-9]"), "");
        perStrip = int.tryParse(numStr) ?? 1;
      }
      if (perStrip <= 0) perStrip = 1;

      final double costPerTablet = batch.purchaseRate / perStrip;
      final double itemCogs = item.totalTabletsSold * costPerTablet;
      final double itemRevenue = item.lineTotal;

      totalRevenue += itemRevenue;
      totalCogs += itemCogs;

      final double profit = itemRevenue - itemCogs;
      // Mark as loss maker if profit margin is less than 5% or it's a loss
      if (profit <= 0 || (itemRevenue > 0 && profit / itemRevenue < 0.05)) {
        lossMakers.add(LossItem(product.name, profit, itemRevenue, itemCogs));
      }
    }

    final map = <String, LossItem>{};
    for (final lm in lossMakers) {
      if (map.containsKey(lm.productName)) {
        final existing = map[lm.productName]!;
        map[lm.productName] = LossItem(
          lm.productName,
          existing.profit + lm.profit,
          existing.soldPrice + lm.soldPrice,
          existing.costPrice + lm.costPrice,
        );
      } else {
        map[lm.productName] = lm;
      }
    }
    
    final aggregatedLossMakers = map.values.toList()
      ..sort((a, b) => a.profit.compareTo(b.profit));

    return ProfitLossStats(
      totalRevenue,
      totalCogs,
      totalRevenue - totalCogs,
      aggregatedLossMakers,
    );
  }
}

class ProfitLossStats {
  final double revenue;
  final double cogs;
  final double grossProfit;
  final List<LossItem> lossMakers;
  ProfitLossStats(this.revenue, this.cogs, this.grossProfit, this.lossMakers);
}

class LossItem {
  final String productName;
  final double profit;
  final double soldPrice;
  final double costPrice;
  LossItem(this.productName, this.profit, this.soldPrice, this.costPrice);
}

class CashFlowStats {
  final double cashUpiRevenue;
  final double creditAdded;
  CashFlowStats(this.cashUpiRevenue, this.creditAdded);
}

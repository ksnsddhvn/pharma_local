import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/sales_tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/receipt_composer.dart';
import '../../core/utils/pdf_invoice_generator.dart';
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Sales & Accounts Dashboard'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.history, size: 18), text: 'Paid'),
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Outstanding'),
            Tab(icon: Icon(Icons.shopping_cart_checkout, size: 18), text: 'Shortbook'),
          ],
        ),
      ),
      body: Column(
        children: [
          _HighContrastDashboardCard(),
          SizedBox(
            height: 150,
            child: _WeeklySalesChart(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _PaidTransactionsTab(),
                _OutstandingAccountsTab(),
                _ShortbookTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sales/new'),
        icon: Icon(Icons.add_shopping_cart),
        label: Text('New Sale', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _PaidTransactionsTab extends ConsumerStatefulWidget {
  const _PaidTransactionsTab();
  @override
  ConsumerState<_PaidTransactionsTab> createState() => _PaidTransactionsTabState();
}

class _PaidTransactionsTabState extends ConsumerState<_PaidTransactionsTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentInvoicesAsync = ref.watch(recentInvoicesStreamProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by Customer Name or Mobile...',
              prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
              filled: true,
              fillColor: context.colors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: TextStyle(color: context.colors.textPrimary),
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: recentInvoicesAsync.when(
            data: (invoices) {
              var paidInvoices = invoices.where((inv) => inv.paymentMode != PaymentMode.credit).toList();
              
              if (_searchQuery.isNotEmpty) {
                paidInvoices = paidInvoices.where((inv) => 
                  inv.customerName.toLowerCase().contains(_searchQuery) ||
                  inv.customerMobile.toLowerCase().contains(_searchQuery) ||
                  inv.invoiceNumber.toLowerCase().contains(_searchQuery)
                ).toList();
              }
              
              if (paidInvoices.isEmpty) {
                return Center(
                  child: Text('No paid transactions found.', style: TextStyle(color: context.colors.textSecondary)),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: paidInvoices.length,
                itemBuilder: (_, i) {
                  final inv = paidInvoices[i];
                  return GestureDetector(
                    onTap: () => showReceiptDialog(context, ref, inv),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(inv.invoiceNumber, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                            Text(AppFormatters.currency(inv.totalAmount), style: TextStyle(color: context.colors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Customer: ${inv.customerName}', style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
                        Text('Mobile: ${inv.customerMobile}', style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
                        Text('Date: ${AppFormatters.date(inv.createdAt)}', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(inv.paymentMode.name.toUpperCase(), style: TextStyle(color: context.colors.textSecondary, fontSize: 11)),
                        ),
                      ],
                    ),
                  ));
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _OutstandingAccountsTab extends ConsumerStatefulWidget {
  const _OutstandingAccountsTab();
  @override
  ConsumerState<_OutstandingAccountsTab> createState() => _OutstandingAccountsTabState();
}

class _OutstandingAccountsTabState extends ConsumerState<_OutstandingAccountsTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentInvoicesAsync = ref.watch(recentInvoicesStreamProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by Customer Name or Mobile...',
              prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
              filled: true,
              fillColor: context.colors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: TextStyle(color: context.colors.textPrimary),
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: recentInvoicesAsync.when(
            data: (invoices) {
              var outstandingAccounts = invoices.where((inv) => inv.creditBalanceAdded > 0).toList();
              
              if (_searchQuery.isNotEmpty) {
                outstandingAccounts = outstandingAccounts.where((inv) => 
                  inv.customerName.toLowerCase().contains(_searchQuery) ||
                  inv.customerMobile.toLowerCase().contains(_searchQuery) ||
                  inv.invoiceNumber.toLowerCase().contains(_searchQuery)
                ).toList();
              }
              
              if (outstandingAccounts.isEmpty) {
                return Center(
                  child: Text('No outstanding accounts found.', style: TextStyle(color: context.colors.textSecondary)),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: outstandingAccounts.length,
                itemBuilder: (_, i) {
                  final inv = outstandingAccounts[i];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _confirmSettle(context, ref, inv),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.error.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(inv.customerName, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(AppFormatters.currency(inv.creditBalanceAdded), style: TextStyle(color: context.colors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: context.colors.textMuted),
                                SizedBox(width: 4),
                                Text(inv.customerMobile, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: context.colors.textMuted),
                                SizedBox(width: 4),
                                Text('Transaction Date: ${AppFormatters.date(inv.createdAt)}', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                              ],
                            ),
                            if (inv.customerNotes != null && inv.customerNotes!.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Note: ${inv.customerNotes}', style: TextStyle(color: context.colors.warning, fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSettle(BuildContext context, WidgetRef ref, SalesInvoice inv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceElevated,
        title: Text('Settle Account', style: TextStyle(color: context.colors.textPrimary)),
        content: Text(
          'Mark ₹${inv.creditBalanceAdded.toStringAsFixed(2)} as paid by ${inv.customerName}?',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: context.colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(salesDaoProvider).settleInvoice(inv.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account settled successfully.'),
          backgroundColor: context.colors.success,
        ));
      }
    }
  }
}

void showReceiptDialog(BuildContext context, WidgetRef ref, SalesInvoice invoice) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => FutureBuilder<List<ReceiptLineItem>>(
      future: ref.read(salesDaoProvider).getItemsForInvoice(invoice.id).then((items) {
        return items.map((i) => ReceiptLineItem(
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: i.totalTabletsSold,
          mrp: i.mrpPerTablet,
          discountPercent: i.discountPercent,
          gstPercent: i.gstPercentage,
          lineTotal: i.lineTotal,
          hsnCode: '',
          packagingUnit: i.packagingUnit,
        )).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SafeArea(
            child: Container(
              height: 300,
              margin: EdgeInsets.all(16).copyWith(top: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final receiptItems = snapshot.data ?? [];
        final receiptText = ReceiptComposer.generateWhatsAppInvoice(
          invoice: invoice,
          items: receiptItems,
        );

        return SafeArea(
          child: Container(
            margin: EdgeInsets.all(16).copyWith(top: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                AppBar(
                  title: Text('Receipt ${invoice.invoiceNumber}', style: TextStyle(fontSize: 16)),
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: context.colors.error),
                      tooltip: 'Cancel Sale',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (c) => AlertDialog(
                            backgroundColor: context.colors.surfaceElevated,
                            title: Text('Cancel Sale?'),
                            content: Text('This will delete the invoice and return all items to inventory. This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: Text('No')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
                                child: Text('Yes, Cancel Sale', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await ref.read(checkoutServiceProvider).cancelSale(invoice.id);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Sale cancelled & stock restored.')));
                            }
                          } catch (e) {
                            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        receiptText,
                        style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Share.share(receiptText),
                              icon: Icon(Icons.share, size: 18),
                              label: Text('Share'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final phone = invoice.customerMobile.trim().isEmpty ? null : '91${invoice.customerMobile.trim().replaceAll(RegExp(r'[^0-9]'), '')}';
                                ReceiptComposer.launchWhatsApp(text: receiptText, phone: phone);
                              },
                              icon: Icon(Icons.chat, size: 18),
                              label: Text('WhatsApp'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Printing.layoutPdf(
                              onLayout: (format) => PdfInvoiceGenerator.generate(invoice, receiptItems),
                              name: 'Invoice_${invoice.invoiceNumber}.pdf',
                            );
                          },
                          icon: Icon(Icons.print, size: 18),
                          label: Text('Print / PDF Receipt'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _HighContrastDashboardCard extends ConsumerWidget {
  const _HighContrastDashboardCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtAsync = ref.watch(overallDebtProvider);
    final revenueAsync = ref.watch(monthlyRevenueProvider);

    final debt = debtAsync.valueOrNull ?? 0.0;
    final revenue = revenueAsync.valueOrNull ?? 0.0;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Debt', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  AppFormatters.currency(debt),
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Revenue', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  AppFormatters.currency(revenue),
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortbookTab extends ConsumerWidget {
  const _ShortbookTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortbookAsync = ref.watch(shortbookItemsProvider);

    return shortbookAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('No shortbook items.', style: TextStyle(color: context.colors.textSecondary)));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final payload = items[i];
            final ratio = payload.threshold > 0 ? payload.currentStock / payload.threshold : 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payload.product.name, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                        Text('Current Stock: ${payload.currentStock} / Min: ${payload.threshold.toStringAsFixed(0)}', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ratio == 0 ? context.colors.expiryCritical.withValues(alpha: 0.1) : context.colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(ratio == 0 ? 'Out of Stock' : 'Low Stock', style: TextStyle(color: ratio == 0 ? context.colors.expiryCritical : context.colors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _WeeklySalesChart extends ConsumerWidget {
  const _WeeklySalesChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySalesAsync = ref.watch(weeklySalesProvider);

    return weeklySalesAsync.when(
      data: (sales) {
        if (sales.isEmpty) return SizedBox.shrink();
        
        final sortedKeys = sales.keys.toList()..sort();
        if (sortedKeys.isEmpty) return SizedBox.shrink();

        double maxVal = 0;
        for (final val in sales.values) {
          if (val > maxVal) maxVal = val;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.surfaceBorder),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal > 0 ? maxVal * 1.2 : 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sortedKeys.length) return SizedBox.shrink();
                      final date = sortedKeys[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(color: context.colors.textMuted, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barGroups: sortedKeys.asMap().entries.map((entry) {
                final idx = entry.key;
                final date = entry.value;
                final val = sales[date] ?? 0.0;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: context.colors.primary,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Chart Error: $e')),
    );
  }
}


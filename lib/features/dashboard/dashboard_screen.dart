import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysSales = ref.watch(todaysSalesTotalProvider);
    final shortbookCount = ref.watch(shortbookCountProvider);
    final expiringCount = ref.watch(expiringBatchesCountProvider);
    final weeklySales = ref.watch(weeklySalesProvider);
    final paymentBreakdown = ref.watch(paymentModeBreakdownProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Low Stock Alerts List
                _LowStockAlertsWidget(),
                
                // Summary Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: "Today's Sales",
                        value: todaysSales.when(
                          data: AppFormatters.currency,
                          loading: () => '...',
                          error: (_, __) => '—',
                        ),
                        icon: Icons.point_of_sale,
                        color: context.colors.primary,
                        onTap: () => context.go('/sales'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Low Stock',
                        value: shortbookCount.when(
                          data: (n) => '$n items',
                          loading: () => '...',
                          error: (_, __) => '—',
                        ),
                        icon: Icons.warning_amber_rounded,
                        color: context.colors.warning,
                        onTap: () => context.go('/reports'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Expiring Soon',
                        value: expiringCount.when(
                          data: (n) => '$n batches',
                          loading: () => '...',
                          error: (_, __) => '—',
                        ),
                        icon: Icons.hourglass_bottom_rounded,
                        color: context.colors.expiryCritical,
                        onTap: () => context.go('/reports'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Quick Sale',
                        value: 'Tap to open',
                        icon: Icons.add_shopping_cart_rounded,
                        color: context.colors.info,
                        onTap: () => context.go('/sales'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // 7-day sales chart
                _WeeklySalesChart(weeklySales: weeklySales),
                SizedBox(height: 24),
                
                // Payment Breakdown Chart
                _PaymentModePieChart(breakdown: paymentBreakdown),
                SizedBox(height: 24),

                // Quick Actions
                _QuickActionsSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: context.colors.surface,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: context.colors.textPrimary),
          onPressed: () => context.push('/settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sri Ranga Medical',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySalesChart extends StatelessWidget {
  final AsyncValue<Map<DateTime, double>> weeklySales;
  const _WeeklySalesChart({required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-Day Sales',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: weeklySales.when(
              data: (data) => _buildChart(context, data),
              loading: () => Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.colors.primary)),
              error: (_, __) =>
                  Center(child: Text('Chart unavailable')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, Map<DateTime, double> data) {
    final days = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final bars = days.asMap().entries.map((e) {
      final val = data[e.value] ?? 0.0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: val,
            color: context.colors.primary,
            width: 24,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          )
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: bars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: context.colors.surfaceBorder,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final day = days[val.toInt()];
                return Text(
                  DateFormat('E').format(day),
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 11),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => context.colors.surfaceBorder,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              AppFormatters.currency(rod.toY),
              TextStyle(color: context.colors.primary, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _ActionTile(
              icon: Icons.point_of_sale,
              label: 'New Sale',
              color: context.colors.primary,
              onTap: () => context.push('/sales/new'),
            ),
            SizedBox(width: 10),
            _ActionTile(
              icon: Icons.add_box_outlined,
              label: 'Receive Stock',
              color: context.colors.info,
              onTap: () => context.push('/inventory/receive'),
            ),
            SizedBox(width: 10),
            _ActionTile(
              icon: Icons.medication_outlined,
              label: 'New Medicine',
              color: context.colors.success,
              onTap: () => context.push('/products/add'),
            ),
            SizedBox(width: 10),
            _ActionTile(
              icon: Icons.book_outlined,
              label: 'Shortbook',
              color: context.colors.warning,
              onTap: () => context.go('/reports'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentModePieChart extends StatelessWidget {
  final AsyncValue<Map<String, double>> breakdown;
  const _PaymentModePieChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '30-Day Payment Methods',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: breakdown.when(
              data: (data) {
                if (data.isEmpty || data.values.every((v) => v == 0)) {
                  return Center(child: Text('No data yet', style: TextStyle(color: context.colors.textSecondary)));
                }
                return _buildChart(context, data);
              },
              loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary)),
              error: (_, __) => Center(child: Text('Chart unavailable')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, Map<String, double> data) {
    final colors = [
      context.colors.primary,
      context.colors.info,
      context.colors.success,
      context.colors.warning,
      context.colors.expiryCritical,
    ];

    int i = 0;
    final sections = data.entries.where((e) => e.value > 0).map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: e.value,
        title: '${e.key}\n${AppFormatters.currency(e.value)}',
        titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        color: color,
        radius: 60,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}

class _LowStockAlertsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(lowStockAlertsProvider);
    
    return alerts.when(
      data: (items) {
        if (items.isEmpty) return SizedBox.shrink();
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: context.colors.warning, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Low Stock Alerts',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final currentStock = item.batches.fold<int>(0, (sum, b) => sum + b.currentStock);
                    return Container(
                      width: 140,
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.warning.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Stock: $currentStock',
                            style: TextStyle(
                              color: context.colors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Min: ${item.product.minStockThreshold}',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}

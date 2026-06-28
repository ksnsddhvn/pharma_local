import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/stock_batches_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class InventoryScreen extends ConsumerWidget {
  InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            tooltip: 'Receive Stock',
            onPressed: () => context.push('/inventory/receive'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          padding: EdgeInsets.only(bottom: 80, top: 8),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductInventoryCard(product: products[i]),
        ),
        loading: () =>
            Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/receive'),
        icon: Icon(Icons.add),
        label: Text('Receive Stock'),
      ),
    );
  }
}

class _ProductInventoryCard extends ConsumerWidget {
  final dynamic product;
  const _ProductInventoryCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesForProductProvider(product.id));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.zero,
        collapsedIconColor: context.colors.textMuted,
        iconColor: context.colors.primary,
        title: Text(
          '${product.name} (${product.packagingUnit})',
          style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        subtitle: batchesAsync.when(
          data: (batches) {
            final total =
                batches.fold<int>(0, (sum, b) => sum + b.currentStock);
            return Text(
              '$total units across ${batches.length} batch(es)',
              style: TextStyle(
                color: total == 0
                    ? context.colors.expiryCritical
                    : total < 10
                        ? context.colors.expiryWarning
                        : context.colors.textSecondary,
                fontSize: 12,
              ),
            );
          },
          loading: () =>
              Text('Loading...', style: TextStyle(fontSize: 12)),
          error: (_, __) => Text('Error'),
        ),
        children: [
          batchesAsync.when(
            data: (batches) => Column(
              children: [
                Divider(height: 1),
                ...batches.map((b) => _BatchRow(batch: b)),
                if (batches.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No stock batches',
                        style: TextStyle(color: context.colors.textMuted)),
                  ),
              ],
            ),
            loading: () => LinearProgressIndicator(),
            error: (_, __) => SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BatchRow extends StatelessWidget {
  final dynamic batch;
  const _BatchRow({required this.batch});

  Color _expiryColor(BuildContext context) {
    final days = batch.expiryDate.difference(DateTime.now()).inDays;
    if (days < 0) return context.colors.expiryCritical;
    if (days <= 30) return context.colors.expiryCritical;
    if (days <= 90) return context.colors.expiryWarning;
    return context.colors.expiryGood;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch: ${batch.batchNumber}',
                  style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: _expiryColor(context)),
                    SizedBox(width: 4),
                    Text(
                      AppFormatters.expiryLabel(batch.expiryDate),
                      style:
                          TextStyle(color: _expiryColor(context), fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  'MRP: ${AppFormatters.currency(batch.mrp)} | GST: ${batch.gstPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: context.colors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: batch.currentStock == 0
                  ? context.colors.expiryCritical.withOpacity(0.15)
                  : context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${batch.currentStock} qty',
              style: TextStyle(
                color: batch.currentStock == 0
                    ? context.colors.expiryCritical
                    : context.colors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

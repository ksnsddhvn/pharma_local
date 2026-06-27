import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/stock_batches_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Receive Stock',
            onPressed: () => context.push('/inventory/receive'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 8),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductInventoryCard(product: products[i]),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/receive'),
        icon: const Icon(Icons.add),
        label: const Text('Receive Stock'),
      ),
    );
  }
}

class _ProductInventoryCard extends ConsumerWidget {
  final dynamic product;
  const _ProductInventoryCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(
      StreamProvider<List<StockBatch>>((ref) => ref.watch(stockBatchesDaoProvider)
          .watchBatchesForProduct(product.id)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.zero,
        collapsedIconColor: AppColors.textMuted,
        iconColor: AppColors.primary,
        title: Text(
          product.name,
          style: const TextStyle(
              color: AppColors.textPrimary,
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
                    ? AppColors.expiryCritical
                    : total < product.minStockThreshold
                        ? AppColors.expiryWarning
                        : AppColors.textSecondary,
                fontSize: 12,
              ),
            );
          },
          loading: () =>
              const Text('Loading...', style: TextStyle(fontSize: 12)),
          error: (_, __) => const Text('Error'),
        ),
        children: [
          batchesAsync.when(
            data: (batches) => Column(
              children: [
                const Divider(height: 1),
                ...batches.map((b) => _BatchRow(batch: b)),
                if (batches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No stock batches',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BatchRow extends StatelessWidget {
  final dynamic batch;
  const _BatchRow({required this.batch});

  Color _expiryColor() {
    final days = batch.expiryDate.difference(DateTime.now()).inDays;
    if (days < 0) return AppColors.expiryCritical;
    if (days <= 30) return AppColors.expiryCritical;
    if (days <= 90) return AppColors.expiryWarning;
    return AppColors.expiryGood;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch: ${batch.batchNumber}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: _expiryColor()),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.expiryLabel(batch.expiryDate),
                      style:
                          TextStyle(color: _expiryColor(), fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  'MRP: ${AppFormatters.currency(batch.mrp)} | GST: ${batch.gstPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: batch.currentStock == 0
                  ? AppColors.expiryCritical.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${batch.currentStock} qty',
              style: TextStyle(
                color: batch.currentStock == 0
                    ? AppColors.expiryCritical
                    : AppColors.primary,
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

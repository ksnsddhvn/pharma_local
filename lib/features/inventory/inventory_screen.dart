import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/stock_batches_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsStreamProvider);
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);

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
      body: Column(
        children: [
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return SizedBox.shrink();
              return Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('All'),
                          selected: _selectedCategoryId == null,
                          selectedColor: context.colors.primary.withOpacity(0.2),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategoryId = null);
                          },
                        ),
                      );
                    }
                    final category = categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        selectedColor: context.colors.primary.withOpacity(0.2),
                        onSelected: (selected) {
                          setState(() => _selectedCategoryId = selected ? category.id : null);
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _selectedCategoryId == null
                    ? products
                    : products.where((p) => p.categoryId == _selectedCategoryId).toList();
                
                if (filtered.isEmpty) {
                   return Center(child: Text('No products in this category.', style: TextStyle(color: context.colors.textSecondary)));
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ProductInventoryCard(product: filtered[i]),
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
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
      child: InkWell(
        onTap: () => context.push('/inventory/product/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.name} (${product.packagingUnit})',
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    batchesAsync.when(
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
                            fontSize: 13,
                          ),
                        );
                      },
                      loading: () =>
                          Text('Loading...', style: TextStyle(fontSize: 13)),
                      error: (_, __) => Text('Error'),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchRow extends ConsumerWidget {
  final dynamic batch;
  const _BatchRow({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCritical = batch.expiryDate.difference(DateTime.now()).inDays < 30;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch: ${batch.batchNumber}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary),
                ),
                Text(
                  'Exp: ${batch.expiryDate.year}-${batch.expiryDate.month.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCritical
                        ? context.colors.expiryCritical
                        : context.colors.textMuted,
                    fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Stock: ${batch.currentStock}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary),
              ),
              Text(
                'MRP: ₹${batch.mrp.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: context.colors.textMuted),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.error, size: 20),
            padding: EdgeInsets.only(left: 16),
            constraints: BoxConstraints(),
            tooltip: 'Delete Batch',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete Batch?'),
                  content: Text('Are you sure you want to delete batch ${batch.batchNumber}? This will remove its remaining stock (${batch.currentStock}) from inventory.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                try {
                  await ref.read(stockBatchesDaoProvider).deleteBatch(batch.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Batch deleted successfully')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
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

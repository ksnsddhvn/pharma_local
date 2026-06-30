import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/daos/products_dao.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

final _productDetailFamily = StreamProvider.family<ProductDetailedPayload, int>((ref, id) {
  return ref.watch(productsDaoProvider).watchProductCompleteDetails(id);
});

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_productDetailFamily(productId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Deep Inventory Inspection'),
      ),
      body: detailAsync.when(
        data: (payload) {
          final p = payload.product;
          final c = payload.category;
          final batches = payload.batches;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section: Master Structural Data
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: context.colors.gradientCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Badge(
                          label: c?.name ?? 'Uncategorized',
                          icon: Icons.category_outlined,
                          color: context.colors.primary,
                        ),
                        _Badge(
                          label: p.productType,
                          icon: Icons.medication_outlined,
                          color: context.colors.info,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HSN Code: ${p.hsnCode}',
                          style: TextStyle(color: context.colors.textMuted, fontSize: 14),
                        ),
                        Text(
                          'Pack: ${p.packagingUnit}',
                          style: TextStyle(color: context.colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Itemized Batch Sub-list
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text('Active Shelf Batches',
                        style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ],
                ),
              ),

              Expanded(
                child: batches.isEmpty
                    ? Center(
                        child: Text('No batches found on shelf',
                            style: TextStyle(color: context.colors.textMuted)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80, top: 8),
                        itemCount: batches.length,
                        itemBuilder: (ctx, i) {
                          final b = batches[i];
                          final isCritical = b.expiryDate.difference(DateTime.now()).inDays < 30;
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.surfaceBorder),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Batch: ${b.batchNumber}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: context.colors.textPrimary),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: b.currentStock == 0
                                            ? context.colors.expiryCritical.withOpacity(0.15)
                                            : context.colors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${b.currentStock} units',
                                        style: TextStyle(
                                          color: b.currentStock == 0
                                              ? context.colors.expiryCritical
                                              : context.colors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Expiry', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                                        SizedBox(height: 2),
                                        Text(
                                          '${b.expiryDate.year}-${b.expiryDate.month.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isCritical
                                                ? context.colors.expiryCritical
                                                : context.colors.textSecondary,
                                            fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Purchase Rate', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                                        SizedBox(height: 2),
                                        Text(
                                          '₹${b.purchaseRate.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('MRP', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                                        SizedBox(height: 2),
                                        Text(
                                          '₹${b.mrp.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 13, color: context.colors.textPrimary, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

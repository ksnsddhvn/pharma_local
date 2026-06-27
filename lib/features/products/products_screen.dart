import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';
import 'widgets/product_category_badge.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ProductCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add product',
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or composition...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category filter chips
          _CategoryFilter(
            selected: _selectedCategory,
            onChanged: (cat) => setState(() => _selectedCategory = cat),
          ),

          // Product list
          Expanded(
            child: productsAsync.when(
              data: (allProducts) {
                List<Product> filtered = allProducts;

                if (_selectedCategory != null) {
                  filtered = filtered
                      .where((p) => p.category == _selectedCategory)
                      .toList();
                }

                if (_query.isNotEmpty) {
                  filtered = FuzzySearch.filter<Product>(
                    query: _query,
                    candidates: filtered,
                    keyOf: (p) => '${p.name} ${p.composition ?? ''}',
                  );
                }

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.medication_outlined,
                            size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No products found',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ProductTile(product: filtered[i]),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onChanged;
  const _CategoryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _chip(null, 'All'),
          const SizedBox(width: 8),
          _chip(ProductCategory.otc, 'OTC'),
          const SizedBox(width: 8),
          _chip(ProductCategory.rx, 'Rx'),
          const SizedBox(width: 8),
          _chip(ProductCategory.scheduleH, 'Sch-H'),
          const SizedBox(width: 8),
          _chip(ProductCategory.scheduleH1, 'Sch-H1'),
        ],
      ),
    );
  }

  Widget _chip(ProductCategory? cat, String label) {
    final isSelected = selected == cat;
    final color = cat == null ? AppColors.primary : _categoryColor(cat);
    return GestureDetector(
      onTap: () => onChanged(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : AppColors.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Color _categoryColor(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.otc:
        return AppColors.otcColor;
      case ProductCategory.rx:
        return AppColors.rxColor;
      case ProductCategory.scheduleH:
        return AppColors.scheduleHColor;
      case ProductCategory.scheduleH1:
        return AppColors.scheduleH1Color;
    }
  }
}

class _ProductTile extends ConsumerWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
            ProductCategoryBadge(category: product.category),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.composition != null) ...[
              const SizedBox(height: 4),
              Text(
                product.composition!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (product.rackLocation != null) ...[
                  const Icon(Icons.shelves,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    product.rackLocation!,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.qr_code_2,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  product.hsnCode ?? 'No HSN',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined,
              color: AppColors.textMuted, size: 18),
          onPressed: () => context.push('/products/edit/${product.id}'),
        ),
        onTap: () => context.push('/products/edit/${product.id}'),
      ),
    );
  }
}

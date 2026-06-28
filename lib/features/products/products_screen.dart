import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add product',
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or composition...',
                prefixIcon: Icon(Icons.search,
                    color: context.colors.textMuted, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: context.colors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Product list
          Expanded(
            child: productsAsync.when(
              data: (allProducts) {
                List<Product> filtered = allProducts;

                if (_query.isNotEmpty) {
                  filtered = FuzzySearch.filter<Product>(
                    query: _query,
                    candidates: filtered,
                    keyOf: (p) => '${p.name} ${p.hsnCode}',
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.medication_outlined,
                            size: 48, color: context.colors.textMuted),
                        SizedBox(height: 12),
                        Text('No products found',
                            style: TextStyle(color: context.colors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ProductTile(product: filtered[i]),
                );
              },
              loading: () => Center(
                  child: CircularProgressIndicator(color: context.colors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}



class _ProductTile extends ConsumerWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'HSN: ${product.hsnCode} | Unit: ${product.packagingUnit}',
              style: TextStyle(
                  color: context.colors.textSecondary, fontSize: 12),
            ),
            SizedBox(height: 4),
            Row(
              children: [

                Icon(Icons.qr_code_2,
                    size: 12, color: context.colors.textMuted),
                SizedBox(width: 4),
                Text(
                  product.hsnCode ?? 'No HSN',
                  style: TextStyle(
                      color: context.colors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined,
              color: context.colors.textMuted, size: 18),
          onPressed: () => context.push('/products/edit/${product.id}'),
        ),
        onTap: () => context.push('/products/edit/${product.id}'),
      ),
    );
  }
}

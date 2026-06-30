import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/database/tables/stock_batches_table.dart';
import '../../core/database/tables/sales_tables.dart';
import '../../core/utils/product_icon_utils.dart';
import '../../core/services/checkout_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../core/utils/formatters.dart';
import 'on_the_fly_entry_sheet.dart';
import '../../core/widgets/tablet_calculator_sheet.dart';

// Provider to hold the current cart
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  bool addItem(CartItem item) {
    final idx =
        state.indexWhere((i) => i.batchId == item.batchId);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      final totalQty = updated[idx].quantity + item.quantity;
      if (totalQty > item.maxQuantity) return false;
      
      updated[idx] = CartItem(
        batchId: item.batchId,
        productId: item.productId,
        productName: item.productName,
        batchNumber: item.batchNumber,
        quantity: totalQty,
        maxQuantity: item.maxQuantity,
        mrp: item.mrp,
        gstPercentage: item.gstPercentage,
        discountPercent: updated[idx].discountPercent,
        hsnCode: item.hsnCode,
        packagingUnit: item.packagingUnit,
        alternativeName: item.alternativeName,
      );
      state = updated;
    } else {
      if (item.quantity > item.maxQuantity) return false;
      state = [...state, item];
    }
    return true;
  }

  void removeItem(int batchId) =>
      state = state.where((i) => i.batchId != batchId).toList();

  void updateDiscount(int batchId, double discount) {
    state = state.map((i) {
      if (i.batchId == batchId) {
        return CartItem(
          batchId: i.batchId,
          productId: i.productId,
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: i.quantity,
          maxQuantity: i.maxQuantity,
          mrp: i.mrp,
          gstPercentage: i.gstPercentage,
          discountPercent: discount,
          hsnCode: i.hsnCode,
          packagingUnit: i.packagingUnit,
          alternativeName: i.alternativeName,
        );
      }
      return i;
    }).toList();
  }

  bool updateQuantity(int batchId, int qty) {
    if (qty <= 0) {
      removeItem(batchId);
      return true;
    }
    bool success = true;
    state = state.map((i) {
      if (i.batchId == batchId) {
        if (qty > i.maxQuantity) {
          success = false;
          return i;
        }
        return CartItem(
          batchId: i.batchId,
          productId: i.productId,
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: qty,
          maxQuantity: i.maxQuantity,
          mrp: i.mrp,
          gstPercentage: i.gstPercentage,
          discountPercent: i.discountPercent,
          hsnCode: i.hsnCode,
          packagingUnit: i.packagingUnit,
          alternativeName: i.alternativeName,
        );
      }
      return i;
    }).toList();
    return success;
  }

  void clear() => state = [];
}

class NewSaleScreen extends ConsumerStatefulWidget {
  NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }



  Future<void> _addToCart(List<StockBatch> batches, Product product) async {
    final qty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceElevated,
      builder: (ctx) => TabletCalculatorSheet(
        productName: product.name, 
        packagingUnit: product.packagingUnit,
        productType: product.productType,
      ),
    );

    if (qty == null || qty <= 0) return;

    final cart = ref.read(cartProvider);
    int remainingQty = qty;
    bool someAdded = false;

    for (final batch in batches) {
      if (remainingQty <= 0) break;

      final inCart = cart.where((i) => i.batchId == batch.id).fold<int>(0, (sum, i) => sum + i.quantity);
      final availableInBatch = batch.currentStock - inCart;

      if (availableInBatch > 0) {
        final amountToTake = remainingQty > availableInBatch ? availableInBatch : remainingQty;
        
        ref.read(cartProvider.notifier).addItem(
              CartItem(
                batchId: batch.id,
                productId: product.id,
                productName: product.name,
                batchNumber: batch.batchNumber,
                quantity: amountToTake,
                maxQuantity: batch.currentStock,
                mrp: batch.mrp,
                gstPercentage: batch.gstPercentage,
                hsnCode: product.hsnCode,
                packagingUnit: product.packagingUnit,
                productType: product.productType,
                alternativeName: null,
              ),
            );
            
        remainingQty -= amountToTake;
        someAdded = true;
      }
    }

    if (remainingQty > 0) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.colors.surface,
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: context.colors.error),
                SizedBox(width: 8),
                Text('Insufficient Stock'),
              ],
            ),
            content: Text(someAdded 
              ? 'Only added ${qty - remainingQty} tablets. No more stock available across all batches.'
              : 'Not enough available stock to add $qty tablets.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: Text('OK', style: TextStyle(color: context.colors.primary)),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${product.name} added to cart ($qty tablets)'),
        duration: Duration(seconds: 1),
        backgroundColor: context.colors.success,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = cart.fold(0.0, (s, i) => s + i.lineTotal);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Point of Sale'),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              icon: Icon(Icons.delete_outline,
                  color: context.colors.error, size: 18),
              label: Text('Clear',
                  style: TextStyle(color: context.colors.error)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barcode / search row
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search inventory manually...',
                      prefixIcon: Icon(Icons.search,
                          color: context.colors.textMuted, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Category Chips
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(allCategoriesStreamProvider);
              return categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) return SizedBox.shrink();
                  return Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 8),
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
                              setState(() {
                                _selectedCategoryId = selected ? category.id : null;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox.shrink(),
                error: (_, __) => SizedBox.shrink(),
              );
            },
          ),

          // Cart & Search Dropdown
          Expanded(
            child: Stack(
              children: [
                // Cart
                cart.isEmpty
                    ? _EmptyCartPlaceholder()
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 120),
                        itemCount: cart.length,
                        itemBuilder: (_, i) => _CartItemTile(item: cart[i]),
                      ),
                
                // Product search results dropdown
                if (_searchFocusNode.hasFocus || _query.isNotEmpty || _selectedCategoryId != null)
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
                    bottom: 0,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: context.colors.surface,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _SearchResults(
                          query: _query,
                          categoryId: _selectedCategoryId,
                          onAdd: (batches, product) {
                            _searchFocusNode.unfocus();
                            _addToCart(batches, product);
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _selectedCategoryId = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // Checkout bottom bar
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                    top: BorderSide(color: context.colors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${cart.length} item(s)',
                            style: TextStyle(
                                color: context.colors.textSecondary, fontSize: 12)),
                        Text(
                          AppFormatters.currency(cartTotal),
                          style: TextStyle(
                            color: context.colors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/sales/checkout'),
                    icon: Icon(Icons.receipt_long_outlined, size: 18),
                    label: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14)),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SearchResults extends ConsumerStatefulWidget {
  final String query;
  final int? categoryId;
  final Function(List<StockBatch>, Product) onAdd;
  const _SearchResults({required this.query, this.categoryId, required this.onAdd});

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  List<Product> _products = [];
  String _lastQuery = '';
  int? _lastCategoryId;

  @override
  void initState() {
    super.initState();
    _lastQuery = widget.query;
    _lastCategoryId = widget.categoryId;
    _search(widget.query, widget.categoryId);
  }

  @override
  void didUpdateWidget(_SearchResults old) {
    super.didUpdateWidget(old);
    if (widget.query != _lastQuery || widget.categoryId != _lastCategoryId) {
      _lastQuery = widget.query;
      _lastCategoryId = widget.categoryId;
      _search(widget.query, widget.categoryId);
    }
  }

  Future<void> _search(String q, int? catId) async {
    final all = await ref.read(productsDaoProvider).getAllProducts();
    var filtered = all;
    if (catId != null) {
      filtered = filtered.where((p) => p.categoryId == catId).toList();
    }
    
    if (q.isEmpty) {
      if (mounted) setState(() => _products = filtered.take(15).toList());
      return;
    }
    
    final searchResults = FuzzySearch.filter<Product>(
        query: q,
        candidates: filtered,
        keyOf: (p) => '${p.name} ${p.hsnCode}',
      );
    if (mounted) setState(() => _products = searchResults.take(15).toList());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _ProductResultTile(
              product: _products[index],
              onAdd: widget.onAdd,
            ),
            if (index < _products.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16),
          ],
        );
      },
    );
  }
}

class _ProductResultTile extends ConsumerWidget {
  final Product product;
  final Function(List<StockBatch>, Product) onAdd;
  const _ProductResultTile({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<StockBatch>>(
      future: ref.read(stockBatchesDaoProvider).getBatchesForProduct(product.id),
      builder: (context, snapshot) {
        final batches = snapshot.data ?? [];
        final totalStock = batches.fold<int>(0, (sum, b) => sum + b.currentStock);
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return ListTile(
          dense: true,
          title: Row(
            children: [
              Icon(ProductIconUtils.getIconForType(product.productType), size: 16, color: context.colors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text('${product.name} (${product.packagingUnit})',
                    style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HSN: ${product.hsnCode}',
                  style: TextStyle(
                      color: context.colors.textMuted, fontSize: 11)),
              SizedBox(height: 4),
              if (isLoading)
                Text('Loading stock...', style: TextStyle(color: context.colors.textMuted, fontSize: 11))
              else
                Text(
                  totalStock > 0 ? 'In Stock: $totalStock' : 'Out of Stock',
                  style: TextStyle(
                    color: totalStock > 0 ? context.colors.success : context.colors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          trailing: isLoading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : (totalStock > 0
                  ? IconButton(
                      icon: Icon(Icons.add_circle_outline, color: context.colors.primary, size: 22),
                      onPressed: () => onAdd(batches, product),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.colors.error.withOpacity(0.3)),
                      ),
                      child: Text('Out of Stock', style: TextStyle(color: context.colors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
        );
      },
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.productName} (${item.packagingUnit})',
                        style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(
                      'Batch: ${item.batchNumber} | MRP: ${AppFormatters.currency(item.mrp)}',
                      style: TextStyle(
                          color: context.colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close,
                    size: 16, color: context.colors.textMuted),
                onPressed: () => ref
                    .read(cartProvider.notifier)
                    .removeItem(item.batchId),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              // Quantity control
              _QtyButton(
                icon: Icons.remove,
                onTap: () => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.batchId, item.quantity - 1),
              ),
              GestureDetector(
                onTap: () async {
                  final qty = await showModalBottomSheet<int>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: context.colors.surfaceElevated,
                    builder: (ctx) => TabletCalculatorSheet(
                      productName: item.productName, 
                      packagingUnit: item.packagingUnit,
                      productType: item.productType,
                    ),
                  );
                  if (qty != null) {
                    final success = ref.read(cartProvider.notifier).updateQuantity(item.batchId, qty);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Cannot exceed available stock (${item.maxQuantity}) for this batch.'),
                        backgroundColor: context.colors.error,
                      ));
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${item.quantity}',
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration: TextDecoration.underline)),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () {
                  final success = ref.read(cartProvider.notifier).updateQuantity(item.batchId, item.quantity + 1);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Cannot exceed available stock (${item.maxQuantity})'),
                      backgroundColor: context.colors.error,
                    ));
                  }
                },
              ),
              Spacer(),
              // Line total
              Text(
                AppFormatters.currency(item.lineTotal),
                style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.surfaceBorder),
        ),
        child: Icon(icon, size: 16, color: context.colors.primary),
      ),
    );
  }
}

class _EmptyCartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: context.colors.textMuted),
          SizedBox(height: 16),
          Text('Cart is empty',
              style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Search for a product manually to begin',
              style: TextStyle(
                  color: context.colors.textMuted, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

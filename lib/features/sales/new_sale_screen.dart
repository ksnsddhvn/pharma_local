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
import 'package:flutter_slidable/flutter_slidable.dart';
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
      if ((totalQty * item.tierMultiplier) > item.maxQuantity) return false;
      
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
          pricingJson: item.pricingJson,
          selectedTier: item.selectedTier,
          tierMultiplier: item.tierMultiplier,
        );
      state = updated;
    } else {
      if ((item.quantity * item.tierMultiplier) > item.maxQuantity) return false;
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
          pricingJson: i.pricingJson,
          selectedTier: i.selectedTier,
          tierMultiplier: i.tierMultiplier,
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
        if ((qty * i.tierMultiplier) > i.maxQuantity) {
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
          pricingJson: i.pricingJson,
          selectedTier: i.selectedTier,
          tierMultiplier: i.tierMultiplier,
        );
      }
      return i;
    }).toList();
    return success;
  }

  void updatePackagingUnit(int batchId, String unit) {
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
          discountPercent: i.discountPercent,
          hsnCode: i.hsnCode,
          packagingUnit: unit,
          alternativeName: i.alternativeName,
          pricingJson: i.pricingJson,
          selectedTier: i.selectedTier,
          tierMultiplier: i.tierMultiplier,
        );
      }
      return i;
    }).toList();
  }

  
  void updateTier(int batchId, String tier, int multiplier) {
    state = state.map((i) {
      if (i.batchId == batchId) {
        // Adjust quantity to roughly match previous total tablets
        int totalTablets = i.quantity * i.tierMultiplier;
        int newQty = totalTablets ~/ multiplier;
        if (newQty < 1) newQty = 1;
        
        return CartItem(
          batchId: i.batchId,
          productId: i.productId,
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: newQty,
          maxQuantity: i.maxQuantity,
          mrp: i.mrp,
          gstPercentage: i.gstPercentage,
          discountPercent: i.discountPercent,
          hsnCode: i.hsnCode,
          packagingUnit: i.packagingUnit,
          alternativeName: i.alternativeName,
          pricingJson: i.pricingJson,
          selectedTier: tier,
          tierMultiplier: multiplier,
        );
      }
      return i;
    }).toList();
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
        packagingUnit: () {
          final full = product.packagingUnit;
          return full.contains('|{') ? full.split('|').first : full;
        }(),
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
                packagingUnit: () {
                  final full = product.packagingUnit;
                  return full.contains('|{') ? full.split('|').first : full;
                }(),
                pricingJson: () {
                  final full = product.packagingUnit;
                  return full.contains('|{') ? '|' + full.split('|').skip(1).join('|') : null;
                }(),
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
      body: SafeArea(
        child: Column(
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
                              selectedColor: context.colors.primary.withValues(alpha: 0.2),
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
                            selectedColor: context.colors.primary.withValues(alpha: 0.2),
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
    List<Product> filtered;
    if (catId != null) {
      filtered = await ref.read(productsDaoProvider).watchProductsByCategory(catId).first;
    } else {
      filtered = await ref.read(productsDaoProvider).getAllProducts();
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
                child: Text('${product.name} (${product.packagingUnit.split('|').first})',
                    style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
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
                        color: context.colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text('Out of Stock', style: TextStyle(color: context.colors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
        );
      },
    );
  }
}

class _CartItemTile extends ConsumerStatefulWidget {
  final CartItem item;
  const _CartItemTile({required this.item, super.key});

  @override
  ConsumerState<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<_CartItemTile> {
  late TextEditingController _qtyCtrl;
  late TextEditingController _discountCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    _discountCtrl = TextEditingController(text: widget.item.discountPercent.toString());
  }

  @override
  void didUpdateWidget(covariant _CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity && 
        _qtyCtrl.text != widget.item.quantity.toString()) {
      _qtyCtrl.text = widget.item.quantity.toString();
    }
    if (oldWidget.item.discountPercent != widget.item.discountPercent &&
        _discountCtrl.text != widget.item.discountPercent.toString()) {
      _discountCtrl.text = widget.item.discountPercent.toString();
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Slidable(
      key: ValueKey(item.batchId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => ref.read(cartProvider.notifier).removeItem(item.batchId),
            backgroundColor: context.colors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
          ),
        ],
      ),
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.productName} (${item.packagingUnit.split('|').first})',
                          style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 2),
                      Text(
                        'Batch: ${item.batchNumber} | MRP: ${AppFormatters.currency(item.mrp)}',
                        style: TextStyle(
                            color: context.colors.textMuted, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      if (item.pricingJson != null) ...[
                        SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: DropdownButtonFormField<String>(
                            value: item.selectedTier,
                            decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                            items: [
                              DropdownMenuItem(value: 'unit', child: Text('Unit', style: TextStyle(fontSize: 12))),
                              if (item.productType == 'Tablet' || item.productType == 'Capsule')
                                DropdownMenuItem(value: 'sheet', child: Text('Sheet', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'pack', child: Text('Pack', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                int mul = 1;
                                if (val == 'sheet') {
                                  final match = RegExp(r'^([\d\.]+)').firstMatch(item.packagingUnit);
                                  if (match != null) mul = double.parse(match.group(1)!).toInt();
                                  else mul = 10;
                                } else if (val == 'pack') {
                                  final match = RegExp(r'^([\d\.]+)').firstMatch(item.packagingUnit);
                                  int sMul = 10;
                                  if (match != null) sMul = double.parse(match.group(1)!).toInt();
                                  if (item.productType == 'Tablet' || item.productType == 'Capsule') mul = sMul * 10;
                                  else mul = sMul;
                                }
                                ref.read(cartProvider.notifier).updateTier(item.batchId, val, mul);
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _qtyCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      hintText: 'Max: ${item.maxQuantity ~/ item.tierMultiplier}',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      if (parsed > 0) {
                        final success = ref.read(cartProvider.notifier).updateQuantity(item.batchId, parsed);
                        if (!success) {
                          _qtyCtrl.text = (item.maxQuantity ~/ item.tierMultiplier).toString();
                          ref.read(cartProvider.notifier).updateQuantity(item.batchId, item.maxQuantity ~/ item.tierMultiplier);
                        }
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _discountCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Disc %',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      ref.read(cartProvider.notifier).updateDiscount(item.batchId, parsed);
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    AppFormatters.currency(item.lineTotal),
                    style: TextStyle(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/services/checkout_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/barcode_service.dart';
import 'on_the_fly_entry_sheet.dart';

// Provider to hold the current cart
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final idx =
        state.indexWhere((i) => i.batchId == item.batchId);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      updated[idx] = CartItem(
        batchId: item.batchId,
        productId: item.productId,
        productName: item.productName,
        batchNumber: item.batchNumber,
        quantity: updated[idx].quantity + item.quantity,
        mrp: item.mrp,
        gstPercentage: item.gstPercentage,
        category: item.category,
        discountPercent: updated[idx].discountPercent,
      );
      state = updated;
    } else {
      state = [...state, item];
    }
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
          mrp: i.mrp,
          gstPercentage: i.gstPercentage,
          category: i.category,
          discountPercent: discount,
        );
      }
      return i;
    }).toList();
  }

  void updateQuantity(int batchId, int qty) {
    if (qty <= 0) {
      removeItem(batchId);
      return;
    }
    state = state.map((i) {
      if (i.batchId == batchId) {
        return CartItem(
          batchId: i.batchId,
          productId: i.productId,
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: qty,
          mrp: i.mrp,
          gstPercentage: i.gstPercentage,
          category: i.category,
          discountPercent: i.discountPercent,
        );
      }
      return i;
    }).toList();
  }

  void clear() => state = [];
}

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _searchCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  String _query = '';
  bool _showCamera = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeInput(String barcode) async {
    if (barcode.trim().isEmpty) return;
    final result =
        await ref.read(stockBatchesDaoProvider).findByBarcode(barcode.trim());
    if (result == null) {
      if (mounted) {
        final res = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => OnTheFlyEntrySheet(initialName: barcode.trim()),
        );
        if (res != null) {
          _addToCart(res.batch, res.product);
        }
      }
      return;
    }
    _addToCart(result.batch, result.product);
    _barcodeCtrl.clear();
  }

  void _addToCart(StockBatch batch, Product product) {
    ref.read(cartProvider.notifier).addItem(
          CartItem(
            batchId: batch.id,
            productId: product.id,
            productName: product.name,
            batchNumber: batch.batchNumber,
            quantity: 1,
            mrp: batch.mrp,
            gstPercentage: batch.gstPercentage,
            category: product.category,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} added to cart'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = cart.fold(0.0, (s, i) => s + i.lineTotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
              label: const Text('Clear',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barcode / search row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search or type barcode...',
                      prefixIcon: Icon(Icons.search,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Barcode scan button (Android only, hidden on desktop)
                if (BarcodeService.isSupportedPlatform)
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner,
                        color: AppColors.primary),
                    onPressed: () =>
                        setState(() => _showCamera = !_showCamera),
                  )
                else
                  // Desktop fallback: manual barcode entry
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _barcodeCtrl,
                      onSubmitted: _handleBarcodeInput,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Barcode',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, size: 16),
                          onPressed: () =>
                              _handleBarcodeInput(_barcodeCtrl.text),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product search results
          if (_query.isNotEmpty) _SearchResults(
            query: _query,
            onAdd: (batch, product) {
              _addToCart(batch, product);
              _searchCtrl.clear();
              setState(() => _query = '');
            },
          ),

          // Cart
          Expanded(
            child: cart.isEmpty
                ? _EmptyCartPlaceholder()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: cart.length,
                    itemBuilder: (_, i) => _CartItemTile(item: cart[i]),
                  ),
          ),
        ],
      ),

      // Checkout bottom bar
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${cart.length} item(s)',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        Text(
                          AppFormatters.currency(cartTotal),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/sales/checkout'),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
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
  final Function(StockBatch, Product) onAdd;
  const _SearchResults({required this.query, required this.onAdd});

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  List<Product> _products = [];
  String _lastQuery = '';

  @override
  void didUpdateWidget(_SearchResults old) {
    super.didUpdateWidget(old);
    if (widget.query != _lastQuery) {
      _lastQuery = widget.query;
      _search(widget.query);
    }
  }

  Future<void> _search(String q) async {
    final all = await ref.read(productsDaoProvider).getAllProducts();
    final filtered = FuzzySearch.filter<Product>(
        query: q,
        candidates: all,
        keyOf: (p) => '${p.name} ${p.composition ?? ''}',
      );
    if (mounted) setState(() => _products = filtered.take(6).toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_lastQuery != widget.query) _search(widget.query);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: _products.map((p) => _ProductResultTile(
          product: p,
          onAdd: widget.onAdd,
        )).toList(),
      ),
    );
  }
}

class _ProductResultTile extends ConsumerWidget {
  final Product product;
  final Function(StockBatch, Product) onAdd;
  const _ProductResultTile({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      title: Text(product.name,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      subtitle: Text(product.composition ?? '',
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline,
            color: AppColors.primary, size: 22),
        onPressed: () async {
          final batches = await ref
              .read(stockBatchesDaoProvider)
              .getBatchesForProduct(product.id);
          if (batches.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('No stock available'),
                  backgroundColor: AppColors.warning));
            }
            return;
          }
          // FEFO — take first (nearest expiry) batch with stock
          final batch = batches.first;
          onAdd(batch, product);
        },
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(
                      'Batch: ${item.batchNumber} | MRP: ${AppFormatters.currency(item.mrp)}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.textMuted),
                onPressed: () => ref
                    .read(cartProvider.notifier)
                    .removeItem(item.batchId),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Quantity control
              _QtyButton(
                icon: Icons.remove,
                onTap: () => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.batchId, item.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item.quantity}',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.batchId, item.quantity + 1),
              ),
              const Spacer(),
              // Line total
              Text(
                AppFormatters.currency(item.lineTotal),
                style: const TextStyle(
                    color: AppColors.primary,
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _EmptyCartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('Cart is empty',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Search for a product or scan a barcode to begin',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

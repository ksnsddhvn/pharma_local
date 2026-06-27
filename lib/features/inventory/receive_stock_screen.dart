import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/services/inventory_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({super.key});

  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  int? _selectedSupplierId;

  final _batchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _mrpCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _invoiceAmtCtrl = TextEditingController();
  final _invoiceNoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  double _gst = 12.0;
  DateTime _expiry = DateTime.now().add(const Duration(days: 365));
  bool _loading = false;
  bool _showSearch = false;
  bool _isOpeningStock = false;

  @override
  void dispose() {
    _batchCtrl.dispose();
    _qtyCtrl.dispose();
    _mrpCtrl.dispose();
    _rateCtrl.dispose();
    _invoiceAmtCtrl.dispose();
    _invoiceNoCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: AppColors.warning));
      return;
    }
    if (!_isOpeningStock && _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: AppColors.warning));
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isOpeningStock) {
        await ref.read(openingStockServiceProvider).addOpeningStock(
              productId: _selectedProduct!.id,
              batchNumber: _batchCtrl.text.trim(),
              expiryDate: _expiry,
              mrp: double.parse(_mrpCtrl.text),
              quantity: int.parse(_qtyCtrl.text),
            );
      } else {
        await ref.read(inventoryServiceProvider).receivePurchase(
              productId: _selectedProduct!.id,
              batchNumber: _batchCtrl.text.trim(),
              expiryDate: _expiry,
              mrp: double.parse(_mrpCtrl.text),
              purchaseRate: double.parse(_rateCtrl.text),
              gstPercentage: _gst,
              quantity: int.parse(_qtyCtrl.text),
              supplierId: _selectedSupplierId!,
              invoiceAmount: double.parse(_invoiceAmtCtrl.text),
              invoiceNumber: _invoiceNoCtrl.text.trim().isEmpty
                  ? null
                  : _invoiceNoCtrl.text.trim(),
              referenceNote: _noteCtrl.text.trim().isEmpty
                  ? null
                  : _noteCtrl.text.trim(),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Stock received successfully ✓'),
            backgroundColor: AppColors.success));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(allSuppliersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receive Stock'),
        actions: [
          if (_loading)
            const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)))
          else
            TextButton(
                onPressed: _submit,
                child: const Text('Save',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Opening Stock Mode', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Bypass supplier and purchase rate for legacy stock', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _isOpeningStock,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _isOpeningStock = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Product selector
            _sectionLabel('Select Product'),
            GestureDetector(
              onTap: () => setState(() => _showSearch = !_showSearch),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _selectedProduct != null
                          ? AppColors.primary
                          : AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_outlined,
                        color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedProduct?.name ?? 'Tap to select product...',
                        style: TextStyle(
                          color: _selectedProduct != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            if (_showSearch) _ProductSearchWidget(
              onSelected: (p) => setState(() {
                _selectedProduct = p;
                _showSearch = false;
              }),
            ),
            const SizedBox(height: 16),

            // Batch details
            _sectionLabel('Batch Details'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _batchCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Batch Number *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickExpiry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(
                            'Expiry: ${_expiry.day}/${_expiry.month}/${_expiry.year}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mrpCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'MRP (₹) *'),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!_isOpeningStock) Expanded(
                        child: TextFormField(
                          controller: _rateCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Purchase Rate (₹) *'),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Quantity *'),
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!_isOpeningStock) Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _gst,
                          dropdownColor: AppColors.surfaceElevated,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(labelText: 'GST %'),
                          items: const [
                            DropdownMenuItem(value: 0.0, child: Text('0%')),
                            DropdownMenuItem(value: 5.0, child: Text('5%')),
                            DropdownMenuItem(value: 12.0, child: Text('12%')),
                            DropdownMenuItem(value: 18.0, child: Text('18%')),
                          ],
                          onChanged: (v) => setState(() => _gst = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Supplier
            if (!_isOpeningStock) ...[
              _sectionLabel('Supplier'),
              suppliersAsync.when(
                data: (suppliers) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedSupplierId,
                      dropdownColor: AppColors.surfaceElevated,
                      isExpanded: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      hint: const Text('Select Supplier',
                          style: TextStyle(color: AppColors.textMuted)),
                      items: suppliers
                          .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSupplierId = v),
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading suppliers'),
              ),
              const SizedBox(height: 16),
            ],

            // Invoice
            if (!_isOpeningStock) ...[
              _sectionLabel('Invoice Details'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _invoiceAmtCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'Invoice Amount (₹) *'),
                      validator: (v) =>
                          double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _invoiceNoCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'Invoice No.'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'Reference Note'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: const Text('Receive Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );
}

class _ProductSearchWidget extends ConsumerStatefulWidget {
  final ValueChanged<Product> onSelected;
  const _ProductSearchWidget({required this.onSelected});

  @override
  ConsumerState<_ProductSearchWidget> createState() =>
      _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends ConsumerState<_ProductSearchWidget> {
  final _ctrl = TextEditingController();
  List<Product> _results = [];

  @override
  void initState() {
    super.initState();
    _load('');
  }

  Future<void> _load(String q) async {
    final all = await ref.read(productsDaoProvider).getAllProducts();
    final filtered = q.isEmpty
        ? all
        : FuzzySearch.filter(
            query: q, candidates: all, keyOf: (p) => p.name);
    if (mounted) setState(() => _results = filtered.take(8).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: _load,
            decoration: const InputDecoration(
              hintText: 'Search product...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Divider(height: 1),
          ..._results.map(
            (p) => ListTile(
              dense: true,
              title: Text(p.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13)),
              subtitle: Text(p.composition ?? '',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
              onTap: () => widget.onSelected(p),
            ),
          ),
        ],
      ),
    );
  }
}

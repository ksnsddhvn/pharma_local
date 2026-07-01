import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/database/tables/supplier_ledgers_table.dart';
import '../../core/services/inventory_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../core/widgets/tablet_calculator_sheet.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  ReceiveStockScreen({super.key});

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
  final _paidAmountCtrl = TextEditingController();
  final _invoiceNoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _gstCtrl = TextEditingController(text: '12');
  DateTime _expiry = DateTime.now().add(Duration(days: 365));
  bool _loading = false;
  bool _showSearch = false;
  bool _isOpeningStock = false;
  LedgerTxType? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _qtyCtrl.addListener(_autoCalculateInvoiceAmount);
    _rateCtrl.addListener(_autoCalculateInvoiceAmount);
    _gstCtrl.addListener(_autoCalculateInvoiceAmount);
  }

  @override
  void dispose() {
    _batchCtrl.dispose();
    _qtyCtrl.dispose();
    _mrpCtrl.dispose();
    _rateCtrl.dispose();
    _invoiceAmtCtrl.dispose();
    _paidAmountCtrl.dispose();
    _invoiceNoCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    _gstCtrl.dispose();
    
    _qtyCtrl.removeListener(_autoCalculateInvoiceAmount);
    _rateCtrl.removeListener(_autoCalculateInvoiceAmount);
    _gstCtrl.removeListener(_autoCalculateInvoiceAmount);
    
    super.dispose();
  }

  void _autoCalculateInvoiceAmount() {
    if (_selectedProduct == null) return;
    
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    final gst = double.tryParse(_gstCtrl.text) ?? 0.0;

    if (qty == 0 || rate == 0) {
      _invoiceAmtCtrl.text = '0.00';
      return;
    }

    int perStrip = 1;
    final unitStr = _selectedProduct!.packagingUnit.toLowerCase();
    if (unitStr.endsWith("'s") || unitStr.endsWith("s")) {
      final numStr = unitStr.replaceAll(RegExp(r"[^0-9]"), "");
      perStrip = int.tryParse(numStr) ?? 1;
    }
    if (perStrip <= 0) perStrip = 1;

    final double totalStrips = qty / perStrip;
    
    if (qty > 0 && rate > 0) {
      final invoiceAmt = totalStrips * rate + (totalStrips * rate * gst / 100);
      _invoiceAmtCtrl.text = invoiceAmt.toStringAsFixed(2);
      
      // Keep paid amount in sync if paying in full automatically
      if (_paymentMethod != null && _paidAmountCtrl.text.isEmpty) {
        _paidAmountCtrl.text = _invoiceAmtCtrl.text;
      }
    } else {
      _invoiceAmtCtrl.text = '0.00';
    }
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: context.colors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a product'),
          backgroundColor: context.colors.warning));
      return;
    }
    if (!_isOpeningStock) {
      if (_invoiceAmtCtrl.text.isEmpty ||
          double.tryParse(_invoiceAmtCtrl.text) == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid invoice amount')));
        return;
      }
      if (_paymentMethod != null) {
        if (_paidAmountCtrl.text.isEmpty || double.tryParse(_paidAmountCtrl.text) == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Invalid paid amount')));
          return;
        }
      }
    }
    if (!_isOpeningStock && _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: context.colors.warning));
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
              gstPercentage: double.parse(_gstCtrl.text),
            );
      } else {
        await ref.read(inventoryServiceProvider).receivePurchase(
              productId: _selectedProduct!.id,
              batchNumber: _batchCtrl.text.trim(),
              expiryDate: _expiry,
              mrp: double.parse(_mrpCtrl.text),
              purchaseRate: double.parse(_rateCtrl.text),
              gstPercentage: double.parse(_gstCtrl.text),
              quantity: int.parse(_qtyCtrl.text),
              supplierId: _selectedSupplierId!,
              invoiceAmount: double.parse(_invoiceAmtCtrl.text),
              barcode: _batchCtrl.text.trim(),
              invoiceNumber: _invoiceNoCtrl.text.trim(),
              referenceNote: _noteCtrl.text.trim(),
              paymentMethod: _paymentMethod,
              paymentAmount: _paymentMethod != null ? double.parse(_paidAmountCtrl.text) : null,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Stock received successfully ✓'),
            backgroundColor: context.colors.success));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.colors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(allSuppliersStreamProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Receive Stock'),
        actions: [
          if (_loading)
            Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.colors.primary)))
          else
            TextButton(
                onPressed: _submit,
                child: Text('Save',
                    style: TextStyle(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text('Opening Stock Mode', style: TextStyle(color: context.colors.textPrimary)),
              subtitle: Text('Bypass supplier and purchase rate for legacy stock', style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
              value: _isOpeningStock,
              activeColor: context.colors.primary,
              onChanged: (v) => setState(() => _isOpeningStock = v),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 16),

            // Product selector
            _sectionLabel('Select Product'),
            GestureDetector(
              onTap: () => setState(() => _showSearch = !_showSearch),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _selectedProduct != null
                          ? context.colors.primary
                          : context.colors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medication_outlined,
                        color: context.colors.textMuted, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedProduct?.name ?? 'Tap to select product...',
                        style: TextStyle(
                          color: _selectedProduct != null
                              ? context.colors.textPrimary
                              : context.colors.textMuted,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down,
                        color: context.colors.textMuted),
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
            SizedBox(height: 16),

            // Batch details
            _sectionLabel('Batch Details'),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.surfaceBorder),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _batchCtrl,
                    textCapitalization: TextCapitalization.none,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(labelText: 'Batch Number *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickExpiry,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.colors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: context.colors.textMuted),
                          SizedBox(width: 10),
                          Text(
                            'Expiry: ${_expiry.day}/${_expiry.month}/${_expiry.year}',
                            style: TextStyle(color: context.colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mrpCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration:
                              InputDecoration(labelText: 'MRP (₹) *'),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      if (!_isOpeningStock) Expanded(
                        child: TextFormField(
                          controller: _rateCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration:
                              InputDecoration(labelText: 'Purchase Rate (₹) *'),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyCtrl,
                          readOnly: true,
                          onTap: () async {
                            if (_selectedProduct == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select a product first', style: TextStyle(color: context.colors.textPrimary)), backgroundColor: context.colors.warning),
                              );
                              return;
                            }
                            final qty = await showModalBottomSheet<int>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: context.colors.surfaceElevated,
                              builder: (ctx) => TabletCalculatorSheet(
                                productName: _selectedProduct!.name,
                                packagingUnit: _selectedProduct!.packagingUnit,
                                productType: _selectedProduct!.productType,
                              ),
                            );
                            if (qty != null) {
                              _qtyCtrl.text = qty.toString();
                            }
                          },
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            labelText: _selectedProduct == null 
                                ? 'Quantity *' 
                                : (_selectedProduct!.productType == 'Tablet' || _selectedProduct!.productType == 'Capsule')
                                    ? 'Total Tablets/Capsules *'
                                    : 'Total ${_selectedProduct!.productType}s *',
                            hintText: 'Tap to calculate',
                          ),
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _gstCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: context.colors.textPrimary),
                          decoration:
                              InputDecoration(labelText: 'GST % *'),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Supplier
            if (!_isOpeningStock) ...[
              _sectionLabel('Supplier'),
              suppliersAsync.when(
                data: (suppliers) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.surfaceBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedSupplierId,
                      dropdownColor: context.colors.surfaceElevated,
                      isExpanded: true,
                      style: TextStyle(color: context.colors.textPrimary),
                      hint: Text('Select Supplier',
                          style: TextStyle(color: context.colors.textMuted)),
                      items: suppliers
                          .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedSupplierId = v;
                        });
                        _autoCalculateInvoiceAmount();
                      },
                    ),
                  ),
                ),
                loading: () => LinearProgressIndicator(),
                error: (_, __) => Text('Error loading suppliers'),
              ),
              SizedBox(height: 16),
            ],

            // Invoice
            if (!_isOpeningStock) ...[
              _sectionLabel('Invoice Details'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _invoiceAmtCtrl,
                      readOnly: true,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Invoice Amount (Auto-Calculated) (₹)',
                        filled: true,
                        fillColor: context.colors.background,
                      ),
                      validator: (v) =>
                          double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _invoiceNoCtrl,
                      textCapitalization: TextCapitalization.none,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: InputDecoration(
                          labelText: 'Invoice No.'),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _noteCtrl,
                      textCapitalization: TextCapitalization.none,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: InputDecoration(
                          labelText: 'Reference Note'),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<LedgerTxType?>(
                      value: _paymentMethod,
                      dropdownColor: context.colors.surfaceElevated,
                      decoration: InputDecoration(
                        labelText: 'Payment Status',
                        filled: true,
                        fillColor: context.colors.background,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Unpaid (Credit)')),
                        DropdownMenuItem(value: LedgerTxType.cashPaid, child: Text('Paid in Cash')),
                        DropdownMenuItem(value: LedgerTxType.upiPaid, child: Text('Paid via UPI')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _paymentMethod = v;
                          if (v != null && _paidAmountCtrl.text.isEmpty) {
                            _paidAmountCtrl.text = _invoiceAmtCtrl.text;
                          }
                        });
                      },
                    ),
                    if (_paymentMethod != null) ...[
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _paidAmountCtrl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Amount Paid (₹) *',
                          filled: true,
                          fillColor: context.colors.background,
                        ),
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text('Receive Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                color: context.colors.textSecondary,
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
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            style: TextStyle(color: context.colors.textPrimary),
            onChanged: _load,
            decoration: InputDecoration(
              hintText: 'Search product...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          Divider(height: 1),
          ..._results.map(
            (p) => ListTile(
              dense: true,
              title: Text(p.name,
                  style: TextStyle(
                      color: context.colors.textPrimary, fontSize: 13)),
              subtitle: Text('HSN: ${p.hsnCode}',
                  style: TextStyle(
                      color: context.colors.textMuted, fontSize: 11)),
              onTap: () => widget.onSelected(p),
            ),
          ),
        ],
      ),
    );
  }
}

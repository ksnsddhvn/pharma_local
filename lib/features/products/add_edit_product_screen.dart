import 'package:drift/drift.dart' as drift;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final int? productId;
  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();

  late TextEditingController _nameCtrl;
  late TextEditingController _packagingAmountCtrl;
  late TextEditingController _packagingUnitCtrl;
  late TextEditingController _hsnCtrl;
  late TextEditingController _priceUnitCtrl;
  late TextEditingController _priceSheetCtrl;
  late TextEditingController _pricePackCtrl;

  // category removed
  final _productTypes = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Cream / Ointment', 'Diaper', 'Powder', 'Toothpaste'];
  late TextEditingController _typeCtrl;
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _packagingAmountCtrl = TextEditingController(text: "10");
    _packagingUnitCtrl = TextEditingController(text: "Tablets");
    _hsnCtrl = TextEditingController();
    _priceUnitCtrl = TextEditingController();
    _priceSheetCtrl = TextEditingController();
    _pricePackCtrl = TextEditingController();


    _typeCtrl = TextEditingController(text: 'Tablet');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _packagingAmountCtrl.dispose();
    _packagingUnitCtrl.dispose();
    _hsnCtrl.dispose();
    _priceUnitCtrl.dispose();
    _priceSheetCtrl.dispose();
    _pricePackCtrl.dispose();
    _typeCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String _getDefaultUnitForType(String type) {
    switch(type) {
      case 'Tablet': return "Tablets";
      case 'Capsule': return "Capsules";
      case 'Syrup': return "ml";
      case 'Injection': return "vials";
      case 'Cream / Ointment': return "grams";
      case 'Diaper': return "Packs";
      case 'Powder':
      case 'Toothpaste': return "grams";
      default: return "Units";
    }
  }

  Future<String?> _showModernDropdown({
    required String title,
    required List<String> items,
    required String? selectedValue,
    bool showCombo = false,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))],
          ),
          child: Column(
            children: [
              SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: context.colors.textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(title, style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    Spacer(),
                    IconButton(icon: Icon(Icons.close, color: context.colors.textMuted), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Divider(height: 1, color: context.colors.surfaceBorder),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    if (item == '+ Add Custom Type' || item == '+ Add Custom Unit') {
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: context.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add, color: context.colors.primary, size: 20),
                        ),
                        title: Text(item, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.pop(ctx, item),
                      );
                    }
                    
                    final isSelected = item == selectedValue;
                    final unit = showCombo ? _getDefaultUnitForType(item) : '';
                    final display = showCombo ? '$item ($unit)' : item;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(display, style: TextStyle(color: isSelected ? context.colors.primary : context.colors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? Icon(Icons.check_circle, color: context.colors.primary) : null,
                      onTap: () => Navigator.pop(ctx, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadProduct() async {
    if (_initialized || widget.productId == null) {
      _initialized = true;
      return;
    }
    _initialized = true;
    final product =
        await ref.read(productsDaoProvider).getProductById(widget.productId!);
    if (product != null && mounted) {
      setState(() {
        _nameCtrl.text = product.name;
        _hsnCtrl.text = product.hsnCode;
        _typeCtrl.text = product.productType;

        final fullPackaging = product.packagingUnit;
        String displayPackaging = fullPackaging;
        if (fullPackaging.contains('|{')) {
          final parts = fullPackaging.split('|');
          displayPackaging = parts[0];
          try {
            final Map<String, dynamic> pricing = jsonDecode(parts.sublist(1).join('|'));
            _priceUnitCtrl.text = pricing['unit']?.toString() ?? '';
            _priceSheetCtrl.text = pricing['sheet']?.toString() ?? '';
            _pricePackCtrl.text = pricing['pack']?.toString() ?? '';
          } catch (_) {}
        }
        final match = RegExp(r'^([\d\.]+)\s*(.*)$').firstMatch(displayPackaging);
        if (match != null) {
          _packagingAmountCtrl.text = match.group(1) ?? '';
          _packagingUnitCtrl.text = match.group(2) ?? '';
        } else {
          _packagingAmountCtrl.text = '';
          _packagingUnitCtrl.text = displayPackaging;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final dao = ref.read(productsDaoProvider);
      final companion = ProductsCompanion(
        id: widget.productId != null
            ? drift.Value(widget.productId!)
            : const drift.Value.absent(),
        name: drift.Value(_nameCtrl.text.trim()),
        packagingUnit: drift.Value(() {
        String pricingJson = '';
        final uText = _priceUnitCtrl.text.trim();
        final sText = _priceSheetCtrl.text.trim();
        final pText = _pricePackCtrl.text.trim();
        final Map<String, dynamic> pricing = {};
        if (uText.isNotEmpty) pricing['unit'] = double.tryParse(uText) ?? 0.0;
        if (sText.isNotEmpty) pricing['sheet'] = double.tryParse(sText) ?? 0.0;
        if (pText.isNotEmpty) pricing['pack'] = double.tryParse(pText) ?? 0.0;
        pricingJson = pricing.isNotEmpty ? '|' + jsonEncode(pricing) : '';
        return '${_packagingAmountCtrl.text.trim()} ${_packagingUnitCtrl.text.trim()}'.trim() + pricingJson;
      }()),
        productType: drift.Value(_typeCtrl.text.trim()),
        hsnCode: drift.Value(_hsnCtrl.text.trim()),
        categoryId: const drift.Value(null),
      );

      if (widget.productId != null) {
        await dao.updateProduct(companion);
      } else {
        await dao.insertProduct(companion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId != null
                ? 'Product updated'
                : 'Product added'),
            backgroundColor: context.colors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) _loadProduct();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
        actions: [
          if (widget.productId != null)
            IconButton(
              onPressed: () async {
                final batches = await ref.read(stockBatchesDaoProvider).getBatchesForProduct(widget.productId!);
                final hasStock = batches.any((b) => b.currentStock > 0);
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.colors.surfaceElevated,
                    title: Text(hasStock ? 'Warning: Active Stock!' : 'Delete Product?'),
                    content: Text(hasStock 
                      ? 'This product still has active stock in your inventory. Deleting it will permanently archive the product. Are you sure you want to proceed?' 
                      : 'This will permanently archive the product. Are you sure?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
                        child: Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await ref.read(productsDaoProvider).deleteProduct(widget.productId!);
                    if (context.mounted) {
                      Navigator.pop(context); // Go back
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              icon: Icon(Icons.delete_outline, color: context.colors.error),
              tooltip: 'Delete Product',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _FormSection(
              title: 'Basic Information',
              children: [
                _field('Medicine Name *', _nameCtrl,
                    hint: 'e.g. Paracetamol 500mg',
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Name is required' : null),
                SizedBox(height: 12),
                TextFormField(
                  controller: _typeCtrl,
                  readOnly: true,
                  onTap: () async {
                    final customTypes = ref.read(customProductTypesProvider);
                    final allTypes = [..._productTypes, ...customTypes, '+ Add Custom Type'];
                    final selected = await _showModernDropdown(
                      title: 'Select Product Type',
                      items: allTypes,
                      selectedValue: _typeCtrl.text,
                      showCombo: true,
                    );
                    if (selected != null) {
                      if (selected == '+ Add Custom Type') {
                        final newType = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            final ctrl = TextEditingController();
                            return AlertDialog(
                              backgroundColor: context.colors.surfaceElevated,
                              title: Text('Add Custom Type'),
                              content: TextField(
                                controller: ctrl,
                                decoration: InputDecoration(hintText: 'e.g. Inhaler, Patches'),
                                textCapitalization: TextCapitalization.words,
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    final val = ctrl.text.trim();
                                    if (val.isNotEmpty) Navigator.pop(ctx, val);
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newType != null && newType.isNotEmpty) {
                          ref.read(customProductTypesProvider.notifier).addType(newType);
                          setState(() {
                            _typeCtrl.text = newType;
                            _packagingUnitCtrl.text = 'Units';
                          });
                        }
                      } else {
                        setState(() {
                          _typeCtrl.text = selected;
                          _packagingUnitCtrl.text = _getDefaultUnitForType(selected);
                        });
                      }
                    }
                  },
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Product Type *',
                    hintText: 'Select or add type',
                    suffixIcon: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.arrow_drop_down, color: context.colors.primary, size: 28),
                    ),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Product type is required' : null,
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _field('Amount *', _packagingAmountCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.trim().isEmpty ? 'Required' : null),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _packagingUnitCtrl,
                        readOnly: true,
                        onTap: () async {
                          final customUnits = ref.read(customProductUnitsProvider);
                          final baseUnits = ['Tablets', 'Capsules', 'ml', 'grams', 'vials', 'Packs', 'Units', 'Large', 'Medium', 'Small'];
                          final allUnits = [...baseUnits, ...customUnits, '+ Add Custom Unit'];
                          final selected = await _showModernDropdown(
                            title: 'Select Unit',
                            items: allUnits,
                            selectedValue: _packagingUnitCtrl.text,
                          );
                          if (selected != null) {
                            if (selected == '+ Add Custom Unit') {
                              final newUnit = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  final ctrl = TextEditingController();
                                  return AlertDialog(
                                    backgroundColor: context.colors.surfaceElevated,
                                    title: Text('Add Custom Unit'),
                                    content: TextField(
                                      controller: ctrl,
                                      decoration: InputDecoration(hintText: 'e.g. Box, Strips'),
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          final val = ctrl.text.trim();
                                          if (val.isNotEmpty) Navigator.pop(ctx, val);
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (newUnit != null && newUnit.isNotEmpty) {
                                ref.read(customProductUnitsProvider.notifier).addUnit(newUnit);
                                setState(() {
                                  _packagingUnitCtrl.text = newUnit;
                                });
                              }
                            } else {
                              setState(() {
                                _packagingUnitCtrl.text = selected;
                              });
                            }
                          }
                        },
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Unit *',
                          hintText: 'Select unit',
                          suffixIcon: Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.arrow_drop_down, color: context.colors.primary, size: 28),
                          ),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _FormSection(
              title: 'Pricing Tiers',
              children: [
                Column(
                  children: [
                    _field('Unit (₹) *', _priceUnitCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    SizedBox(height: 12),
                    _field('Secondary (e.g. Sheet/Box) (₹)', _priceSheetCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    SizedBox(height: 12),
                    _field('Pack (₹)', _pricePackCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _FormSection(
              title: 'GST & Compliance',
              children: [
                _field('HSN Code *', _hsnCtrl,
                    hint: 'e.g. 3004',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.trim().isEmpty ? 'HSN Code is required' : null),

              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(52)),
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    'Save Product',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      TextInputType? keyboardType,
      TextCapitalization textCapitalization = TextCapitalization.characters,
      bool readOnly = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      validator: validator,
      style: TextStyle(color: readOnly ? context.colors.textMuted : context.colors.textPrimary),
      decoration: InputDecoration(
        labelText: label, 
        hintText: hint,
        filled: readOnly,
        fillColor: readOnly ? Colors.black12 : null,
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.surfaceBorder),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }
}



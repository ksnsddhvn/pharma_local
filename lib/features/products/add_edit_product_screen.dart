import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/products_table.dart';
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
  late TextEditingController _compositionCtrl;
  late TextEditingController _hsnCtrl;
  late TextEditingController _rackCtrl;
  late TextEditingController _thresholdCtrl;

  ProductCategory _category = ProductCategory.otc;
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _compositionCtrl = TextEditingController();
    _hsnCtrl = TextEditingController();
    _rackCtrl = TextEditingController();
    _thresholdCtrl = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _compositionCtrl.dispose();
    _hsnCtrl.dispose();
    _rackCtrl.dispose();
    _thresholdCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
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
        _compositionCtrl.text = product.composition ?? '';
        _hsnCtrl.text = product.hsnCode ?? '';
        _rackCtrl.text = product.rackLocation ?? '';
        _thresholdCtrl.text = product.minStockThreshold.toStringAsFixed(0);
        _category = product.category;
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
        composition: drift.Value(_compositionCtrl.text.trim()),
        hsnCode: drift.Value(
            _hsnCtrl.text.trim().isEmpty ? null : _hsnCtrl.text.trim()),
        category: drift.Value(_category),
        rackLocation: drift.Value(
            _rackCtrl.text.trim().isEmpty ? null : _rackCtrl.text.trim()),
        minStockThreshold:
            drift.Value(int.tryParse(_thresholdCtrl.text) ?? 10),
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
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormSection(
              title: 'Basic Information',
              children: [
                _field('Medicine Name *', _nameCtrl,
                    hint: 'e.g. Paracetamol 500mg',
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Name is required' : null),
                const SizedBox(height: 12),
                _field('Composition / Salt *', _compositionCtrl,
                    hint: 'e.g. Paracetamol IP 500mg',
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Composition is required' : null),
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'GST & Compliance',
              children: [
                _field('HSN Code', _hsnCtrl,
                    hint: 'e.g. 3004',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _CategoryDropdown(
                  value: _category,
                  onChanged: (v) => setState(() => _category = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Storage & Reorder',
              children: [
                _field('Rack Location', _rackCtrl,
                    hint: 'e.g. A-12 / Shelf 3'),
                const SizedBox(height: 12),
                _field('Min Stock Threshold', _thresholdCtrl,
                    hint: '10',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
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
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final ProductCategory value;
  final ValueChanged<ProductCategory> onChanged;
  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductCategory>(
      value: value,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Category'),
      items: const [
        DropdownMenuItem(value: ProductCategory.otc, child: Text('OTC — Over the Counter')),
        DropdownMenuItem(value: ProductCategory.rx, child: Text('Rx — Prescription only')),
        DropdownMenuItem(value: ProductCategory.scheduleH, child: Text('Schedule H')),
        DropdownMenuItem(value: ProductCategory.scheduleH1, child: Text('Schedule H1')),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}

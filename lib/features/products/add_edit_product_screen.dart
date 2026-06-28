import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final int? productId;
  AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();

  late TextEditingController _nameCtrl;
  late TextEditingController _packagingCtrl;
  late TextEditingController _hsnCtrl;

  // category removed
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _packagingCtrl = TextEditingController(text: "10's");
    _hsnCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _packagingCtrl.dispose();
    _hsnCtrl.dispose();
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
        _packagingCtrl.text = product.packagingUnit;
        _hsnCtrl.text = product.hsnCode;
        // category removed
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
        packagingUnit: drift.Value(_packagingCtrl.text.trim()),
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
          if (_loading)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.colors.primary)),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Save',
                  style: TextStyle(
                      color: context.colors.primary, fontWeight: FontWeight.w600)),
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
                _field('Packaging Unit *', _packagingCtrl,
                    hint: "e.g. 10's, 15's, 100ml",
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Packaging Unit is required' : null),
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
      style: TextStyle(color: context.colors.textPrimary),
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



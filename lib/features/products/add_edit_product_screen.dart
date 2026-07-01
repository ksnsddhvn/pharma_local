import 'package:drift/drift.dart' as drift;
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
  late TextEditingController _packagingCtrl;
  late TextEditingController _hsnCtrl;

  // category removed
  final _productTypes = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Cream / Ointment', 'Diaper', 'Powder', 'Toothpaste'];
  late TextEditingController _typeCtrl;
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _packagingCtrl = TextEditingController(text: "10's");
    _hsnCtrl = TextEditingController();
    _typeCtrl = TextEditingController(text: 'Tablet');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _packagingCtrl.dispose();
    _hsnCtrl.dispose();
    _typeCtrl.dispose();
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
        _typeCtrl.text = product.productType;
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
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Product Type *',
                    hintText: 'e.g. Tablet, Drops',
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down, color: context.colors.textMuted),
                      color: context.colors.surfaceElevated,
                      onSelected: (String value) async {
                        if (value == '+ Add Custom Type') {
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
                                      if (val.isNotEmpty) {
                                        Navigator.pop(ctx, val);
                                      }
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
                            });
                          }
                          return;
                        }

                        setState(() {
                          _typeCtrl.text = value;
                          // Smartly update packaging unit if it's currently a default
                          final defaults = ["10's", "100ml", "1 Vial", "15g", "1 Pack", "50g", "1 Unit"];
                          if (_packagingCtrl.text.trim().isEmpty || defaults.contains(_packagingCtrl.text.trim())) {
                              switch(value) {
                               case 'Tablet': 
                               case 'Capsule': _packagingCtrl.text = "10's"; break;
                               case 'Syrup': _packagingCtrl.text = "100ml"; break;
                               case 'Injection': _packagingCtrl.text = "1 Vial"; break;
                               case 'Cream / Ointment': _packagingCtrl.text = "15g"; break;
                               case 'Diaper': _packagingCtrl.text = "1 Pack"; break;
                               case 'Powder':
                               case 'Toothpaste': _packagingCtrl.text = "50g"; break;
                               default: _packagingCtrl.text = "1 Unit"; break;
                             }
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        final customTypes = ref.watch(customProductTypesProvider);
                        final allTypes = [..._productTypes, ...customTypes, '+ Add Custom Type'];
                        return allTypes.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: choice == '+ Add Custom Type' 
                                ? Row(children: [Icon(Icons.add, size: 18, color: context.colors.primary), SizedBox(width: 8), Text(choice, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold))])
                                : Text(choice, style: TextStyle(color: context.colors.textPrimary)),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Product type is required' : null,
                ),
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
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/tablet_calculator_sheet.dart';

class OnTheFlyEntrySheet extends ConsumerStatefulWidget {
  final String initialName;
  const OnTheFlyEntrySheet({super.key, required this.initialName});

  @override
  ConsumerState<OnTheFlyEntrySheet> createState() => _OnTheFlyEntrySheetState();
}

class _OnTheFlyEntrySheetState extends ConsumerState<OnTheFlyEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  final _batchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _mrpCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: "10's");

  DateTime _expiry = DateTime.now().add(Duration(days: 365));
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _batchCtrl.dispose();
    _qtyCtrl.dispose();
    _mrpCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await ref.read(openingStockServiceProvider).quickCreateAndAdd(
        name: _nameCtrl.text.trim(),
        batchNumber: _batchCtrl.text.trim(),
        packagingUnit: _unitCtrl.text.trim(),
        expiryDate: _expiry,
        mrp: double.parse(_mrpCtrl.text),
        quantity: int.parse(_qtyCtrl.text),
      );
      if (mounted) Navigator.pop(context, res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: context.colors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Add Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(labelText: 'Product Name *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: InputDecoration(labelText: 'Unit *', hintText: "10's"),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _batchCtrl,
                    decoration: InputDecoration(labelText: 'Batch No *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    readOnly: true,
                    onTap: () async {
                      if (_nameCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter product name first'), backgroundColor: context.colors.warning),
                        );
                        return;
                      }
                      final qty = await showModalBottomSheet<int>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: context.colors.surfaceElevated,
                        builder: (ctx) => TabletCalculatorSheet(productName: _nameCtrl.text, packagingUnit: _unitCtrl.text),
                      );
                      if (qty != null) {
                        _qtyCtrl.text = qty.toString();
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity *', hintText: 'Tap to calculate'),
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mrpCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'MRP (₹) *'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiry,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 3650)),
                      );
                      if (picked != null) setState(() => _expiry = picked);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.surfaceBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Exp: ${_expiry.day}/${_expiry.month}/${_expiry.year}',
                        style: TextStyle(color: context.colors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : Text('Add & Use in Sale'),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

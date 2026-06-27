import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/daos/stock_batches_dao.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

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

  DateTime _expiry = DateTime.now().add(const Duration(days: 365));
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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await ref.read(openingStockServiceProvider).quickCreateAndAdd(
        name: _nameCtrl.text.trim(),
        batchNumber: _batchCtrl.text.trim(),
        expiryDate: _expiry,
        mrp: double.parse(_mrpCtrl.text),
        quantity: int.parse(_qtyCtrl.text),
      );
      if (mounted) Navigator.pop(context, res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
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
            const Text(
              'Quick Add Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _batchCtrl,
                    decoration: const InputDecoration(labelText: 'Batch No *'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity *'),
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mrpCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'MRP (₹) *'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiry,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) setState(() => _expiry = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.surfaceBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Exp: ${_expiry.day}/${_expiry.month}/${_expiry.year}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : const Text('Add & Use in Sale'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

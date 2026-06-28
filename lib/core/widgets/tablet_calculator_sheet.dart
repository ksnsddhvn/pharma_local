import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TabletCalculatorSheet extends StatefulWidget {
  final String productName;
  const TabletCalculatorSheet({super.key, required this.productName});

  @override
  State<TabletCalculatorSheet> createState() => _TabletCalculatorSheetState();
}

class _TabletCalculatorSheetState extends State<TabletCalculatorSheet> {
  final _stripsCtrl = TextEditingController(text: '0');
  final _perStripCtrl = TextEditingController(text: '10');
  final _looseCtrl = TextEditingController(text: '0');

  void _submit() {
    final strips = int.tryParse(_stripsCtrl.text) ?? 0;
    final perStrip = int.tryParse(_perStripCtrl.text) ?? 10;
    final loose = int.tryParse(_looseCtrl.text) ?? 0;
    
    final total = (strips * perStrip) + loose;
    Navigator.pop(context, total);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantity: ${widget.productName}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stripsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Strips/Sheets'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _perStripCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Tablets per Strip'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _looseCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Loose Tablets'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _submit,
              child: const Text('Set Quantity', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

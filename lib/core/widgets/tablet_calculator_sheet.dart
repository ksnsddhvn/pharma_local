import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:pharma_local/core/theme/app_theme.dart';

class TabletCalculatorSheet extends StatefulWidget {
  final String productName;
  final String packagingUnit;
  final String productType;
  TabletCalculatorSheet({super.key, required this.productName, required this.packagingUnit, this.productType = 'Tablet'});

  @override
  State<TabletCalculatorSheet> createState() => _TabletCalculatorSheetState();
}

class _TabletCalculatorSheetState extends State<TabletCalculatorSheet> {
  final _stripsCtrl = TextEditingController(text: '0');
  late final TextEditingController _perStripCtrl;
  final _looseCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    int perStrip = 1;
    final unitStr = widget.packagingUnit.toLowerCase();
    if (unitStr.endsWith("'s") || unitStr.endsWith("s")) {
      final numStr = unitStr.replaceAll(RegExp(r"[^0-9]"), "");
      perStrip = int.tryParse(numStr) ?? 1;
    }
    if (perStrip <= 0) perStrip = 1;
    _perStripCtrl = TextEditingController(text: perStrip.toString());
  }

  void _submit() {
    final isTabletLike = widget.productType == 'Tablet' || widget.productType == 'Capsule';
    final strips = int.tryParse(_stripsCtrl.text) ?? 0;
    final perStrip = int.tryParse(_perStripCtrl.text) ?? 10;
    final loose = int.tryParse(_looseCtrl.text) ?? 0;
    
    final total = isTabletLike ? (strips * perStrip) + loose : loose;
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
          Text('Quantity: ${widget.productName}', style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          if (widget.productType == 'Tablet' || widget.productType == 'Capsule') ...[
            TextField(
              controller: _stripsCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Strips/Sheets',
                hintText: '1 Sheet = ${_perStripCtrl.text} Units',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _looseCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(labelText: 'Loose Units (e.g. single tablets)'),
            ),
          ] else ...[
            TextField(
              controller: _looseCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(labelText: 'Total Quantity (e.g. Bottles, Tubes, Packs)'),
            ),
          ],
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary, padding: EdgeInsets.symmetric(vertical: 14)),
              onPressed: _submit,
              child: Text('Set Quantity', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

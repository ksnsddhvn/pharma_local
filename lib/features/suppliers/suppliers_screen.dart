import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class SuppliersScreen extends ConsumerWidget {
  SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(allSuppliersStreamProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Suppliers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddSupplier(context, ref),
          ),
        ],
      ),
      body: suppliersAsync.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 48, color: context.colors.textMuted),
                  SizedBox(height: 12),
                  Text('No suppliers added',
                      style: TextStyle(color: context.colors.textSecondary)),
                ],
              ),
            );
          }

          final totalOwed = suppliers
              .fold(0.0, (s, sup) => s + sup.currentBalance.clamp(0, double.infinity));

          return Column(
            children: [
              // Total outstanding banner
              if (totalOwed > 0)
                Container(
                  margin: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: context.colors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: context.colors.warning, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Total Outstanding: ${AppFormatters.currency(totalOwed)}',
                        style: TextStyle(
                            color: context.colors.warning,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: suppliers.length,
                  itemBuilder: (_, i) {
                    final s = suppliers[i];
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.surfaceBorder),
                      ),
                      child: Material(
                        color: context.colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(11),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              s.name.isNotEmpty
                                  ? s.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        title: Text(s.name,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (s.phone != null)
                              Text(s.phone!,
                                  style: TextStyle(
                                      color: context.colors.textMuted,
                                      fontSize: 12),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text(
                              s.currentBalance == 0
                                  ? 'Settled ✓'
                                  : s.currentBalance > 0
                                      ? 'Owe: ${AppFormatters.currency(s.currentBalance)}'
                                      : 'Advance: ${AppFormatters.currency(-s.currentBalance)}',
                              style: TextStyle(
                                color: s.currentBalance == 0
                                    ? context.colors.success
                                    : s.currentBalance > 0
                                        ? context.colors.warning
                                        : context.colors.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onTap: () =>
                            context.push('/suppliers/${s.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplier(context, ref),
        backgroundColor: context.colors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSupplier(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceElevated,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Supplier',
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(labelText: 'Supplier Name *'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: contactCtrl,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(labelText: 'Contact Person'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await ref.read(suppliersDaoProvider).insertSupplier(
                      SuppliersCompanion.insert(
                        name: nameCtrl.text.trim(),
                        phone: drift.Value(phoneCtrl.text.trim().isEmpty
                            ? null
                            : phoneCtrl.text.trim()),
                        contactPerson: drift.Value(contactCtrl.text.trim().isEmpty
                            ? null
                            : contactCtrl.text.trim()),
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48)),
              child: Text('Add Supplier'),
            ),
          ],
        ),
      ),
    );
  }
}

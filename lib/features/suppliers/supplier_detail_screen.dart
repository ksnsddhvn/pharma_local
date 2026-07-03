import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/supplier_ledgers_table.dart';
import '../../core/database/daos/suppliers_dao.dart';
import '../../core/providers.dart';
import '../../core/services/supplier_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

final _supplierLedgerFamily = StreamProvider.family<List<SupplierLedger>, int>((ref, id) {
  return ref.watch(supplierLedgerDaoProvider).watchLedgerForSupplier(id);
});

final _supplierDetailFamily = StreamProvider.family<Supplier?, int>((ref, id) {
  return ref.watch(suppliersDaoProvider).watchSupplierById(id);
});

final _supplierPurchasedProductsFamily = StreamProvider.family<List<SupplierProductItem>, int>((ref, id) {
  return ref.watch(suppliersDaoProvider).watchPurchasedProductsForSupplier(id);
});

final _supplierProductsByDateFamily = StreamProvider.family<Map<DateTime, List<SupplierProductItem>>, int>((ref, id) {
  return ref.watch(_supplierPurchasedProductsFamily(id).stream).map((items) {
    final map = <DateTime, List<SupplierProductItem>>{};
    for (var item in items) {
      final d = item.batch.createdAt;
      final date = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(date, () => []).add(item);
    }
    return map;
  });
});

class SupplierDetailScreen extends ConsumerWidget {
  final int supplierId;
  SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(_supplierLedgerFamily(supplierId));
    final supplierAsync = ref.watch(_supplierDetailFamily(supplierId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: supplierAsync.when(
          data: (s) => Text(s?.name ?? 'Supplier'),
          loading: () => Text('Loading...'),
          error: (_, __) => Text('Supplier'),
        ),
        actions: [
          supplierAsync.when(
            data: (s) => TextButton.icon(
              onPressed: () => _showPaymentSheet(context, ref, s?.currentBalance ?? 0),
              icon: Icon(Icons.payment_outlined,
                  color: context.colors.primary, size: 18),
              label: Text('Pay',
                  style: TextStyle(
                      color: context.colors.primary, fontWeight: FontWeight.w600)),
            ),
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
          supplierAsync.when(
            data: (s) => IconButton(
              icon: Icon(Icons.delete_outline, color: context.colors.error),
              tooltip: 'Delete Supplier',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: context.colors.surfaceElevated,
                    title: Text('Delete Supplier?'),
                    content: Text('This will permanently archive the supplier. Are you sure?'),
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
                    await ref.read(suppliersDaoProvider).deleteSupplier(supplierId);
                    if (context.mounted) {
                      Navigator.pop(context); // Go back to list
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Supplier deleted')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Balance header
            supplierAsync.when(
              data: (supplier) {
                if (supplier == null) return SizedBox.shrink();
                return Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: context.colors.gradientCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Outstanding Balance',
                                style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 12)),
                            SizedBox(height: 6),
                            Text(
                              AppFormatters.currency(
                                  supplier.currentBalance.abs()),
                              style: TextStyle(
                                color: supplier.currentBalance == 0
                                    ? context.colors.success
                                    : supplier.currentBalance > 0
                                        ? context.colors.warning
                                        : context.colors.info,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              supplier.currentBalance == 0
                                  ? 'Account settled'
                                  : supplier.currentBalance > 0
                                      ? 'Amount to pay'
                                      : 'Advance credit',
                              style: TextStyle(
                                  color: context.colors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (supplier.phone != null || supplier.contactPerson != null)
                        Column(
                          children: [
                            if (supplier.phone != null) ...[
                              Icon(Icons.phone_outlined,
                                  color: context.colors.textMuted, size: 18),
                              SizedBox(height: 4),
                              Text(supplier.phone!,
                                  style: TextStyle(
                                      color: context.colors.textSecondary,
                                      fontSize: 12)),
                            ],
                            if (supplier.contactPerson != null) ...[
                              SizedBox(height: 8),
                              Icon(Icons.person_outline,
                                  color: context.colors.textMuted, size: 18),
                              SizedBox(height: 4),
                              Text(supplier.contactPerson!,
                                  style: TextStyle(
                                      color: context.colors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ],
                        ),
                    ],
                  ),
                );
              },
              loading: () => LinearProgressIndicator(),
              error: (_, __) => SizedBox.shrink(),
            ),

            // TabBar
            TabBar(
              indicatorColor: context.colors.primary,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.textMuted,
              tabs: const [
                Tab(text: 'Ledger / Payments'),
                Tab(text: 'Purchased Inventory'),
              ],
            ),
            
            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Transaction History
                  ledgerAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Center(
                          child: Text('No transactions yet',
                              style: TextStyle(color: context.colors.textMuted)),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 80, top: 16),
                        itemCount: entries.length,
                        itemBuilder: (_, i) => _LedgerTile(entry: entries[i]),
                      );
                    },
                    loading: () => Center(
                        child: CircularProgressIndicator(color: context.colors.primary)),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),

                  // Tab 2: Purchased Products
                  _PurchasedProductsTab(supplierId: supplierId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, WidgetRef ref, double currentBalance) {
    final defaultAmount = currentBalance > 0 ? currentBalance.toStringAsFixed(2) : '';
    final amtCtrl = TextEditingController(text: defaultAmount);
    final noteCtrl = TextEditingController();
    LedgerTxType type = LedgerTxType.cashPaid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceElevated,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Payment',
                  style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 20),
              TextField(
                controller: amtCtrl,
                autofocus: true,
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: context.colors.textPrimary),
                decoration:
                    InputDecoration(labelText: 'Amount Paid (₹) *'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _payTypeChip(context, LedgerTxType.cashPaid, 'Cash', type,
                      (t) => setModalState(() => type = t)),
                  SizedBox(width: 8),
                  _payTypeChip(context, LedgerTxType.upiPaid, 'UPI', type,
                      (t) => setModalState(() => type = t)),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(labelText: 'UTR / Note'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amtCtrl.text);
                  if (amt == null || amt <= 0) return;
                  await ref.read(supplierServiceProvider).recordPayment(
                        supplierId: supplierId,
                        amount: amt,
                        type: type,
                        referenceNote: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(48)),
                child: Text('Confirm Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payTypeChip(BuildContext context, LedgerTxType t, String label, LedgerTxType selected,
      ValueChanged<LedgerTxType> onTap) {
    final sel = t == selected;
    return GestureDetector(
      onTap: () => onTap(t),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? context.colors.primary.withValues(alpha: 0.15) : context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? context.colors.primary : context.colors.surfaceBorder),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? context.colors.primary : context.colors.textSecondary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _LedgerTile extends ConsumerWidget {
  final SupplierLedger entry;
  const _LedgerTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCredit = entry.transactionType == LedgerTxType.creditPurchase;
    final (label, color, icon) = isCredit
        ? ('Purchase', context.colors.error, Icons.arrow_downward_rounded)
        : ('Payment', context.colors.success, Icons.arrow_upward_rounded);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                Text(
                  AppFormatters.dateTime(entry.timestamp),
                  style: TextStyle(
                      color: context.colors.textMuted, fontSize: 11),
                ),
                if (entry.referenceNote != null)
                  Text(entry.referenceNote!,
                      style: TextStyle(
                          color: context.colors.textMuted, fontSize: 11)),
                if (entry.invoiceNumber != null)
                  Text('Inv: ${entry.invoiceNumber!}',
                      style: TextStyle(
                          color: context.colors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${AppFormatters.currency(entry.amount)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              Text(
                'Bal: ${AppFormatters.currency(entry.balanceAfter)}',
                style: TextStyle(
                    color: context.colors.textMuted, fontSize: 11),
              ),
            ],
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.error, size: 18),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            tooltip: 'Delete entry',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  backgroundColor: context.colors.surfaceElevated,
                  title: Text('Delete Transaction?'),
                  content: Text('This will delete the transaction and revert the supplier balance.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text('No')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
                      child: Text('Yes, Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await ref.read(supplierServiceProvider).deleteLedgerEntry(entry.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction deleted & balance reverted.')));
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
        ],
      ),
      if (isCredit)
        Consumer(
          builder: (context, ref, child) {
            final productsByDateAsync = ref.watch(_supplierProductsByDateFamily(entry.supplierId));
            return productsByDateAsync.when(
              data: (map) {
                final d = entry.timestamp;
                final date = DateTime(d.year, d.month, d.day);
                final items = map[date] ?? [];
                if (items.isEmpty) return SizedBox.shrink();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 24, color: context.colors.surfaceBorder),
                    Text('Items in this invoice:', style: TextStyle(color: context.colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item.product.name} (Batch: ${item.batch.batchNumber})',
                                style: TextStyle(color: context.colors.textPrimary, fontSize: 13)),
                          ),
                          Text('Qty: ${item.batch.currentStock}',
                              style: TextStyle(color: context.colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  ],
                );
              },
              loading: () => SizedBox.shrink(),
              error: (_, __) => SizedBox.shrink(),
            );
          },
        ),
    ],
  ),
);
}
}

class _PurchasedProductsTab extends ConsumerWidget {
  final int supplierId;
  const _PurchasedProductsTab({required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_supplierPurchasedProductsFamily(supplierId));

    return productsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text('No products purchased from this supplier yet',
                style: TextStyle(color: context.colors.textMuted)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.product.name,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.product.productType,
                            style: TextStyle(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('HSN: ${item.product.hsnCode}',
                          style: TextStyle(
                              color: context.colors.textMuted, fontSize: 13)),
                      Text('Batch: ${item.batch.batchNumber}',
                          style: TextStyle(
                              color: context.colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stock: ${item.batch.currentStock} ${item.product.packagingUnit.split('|').first}',
                          style: TextStyle(
                              color: context.colors.textSecondary, fontSize: 13)),
                      Text('Exp: ${AppFormatters.date(item.batch.expiryDate)}',
                          style: TextStyle(
                              color: item.batch.expiryDate.isBefore(DateTime.now()) 
                                ? context.colors.error 
                                : context.colors.textMuted, 
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

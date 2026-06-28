import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/sales_tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales & Accounts Dashboard'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.history, size: 18), text: 'Paid Transactions'),
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Outstanding Accounts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _PaidTransactionsTab(),
          _OutstandingAccountsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sales/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
        label: const Text('New Sale', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _PaidTransactionsTab extends ConsumerWidget {
  const _PaidTransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentInvoicesAsync = ref.watch(recentInvoicesStreamProvider);

    return recentInvoicesAsync.when(
      data: (invoices) {
        final paidInvoices = invoices.where((inv) => inv.paymentMode != PaymentMode.credit).toList();
        
        if (paidInvoices.isEmpty) {
          return const Center(
            child: Text('No paid transactions found.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paidInvoices.length,
          itemBuilder: (_, i) {
            final inv = paidInvoices[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv.invoiceNumber, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      Text(AppFormatters.currency(inv.totalAmount), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ${inv.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('Date: ${AppFormatters.date(inv.createdAt)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(inv.paymentMode.name.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _OutstandingAccountsTab extends ConsumerWidget {
  const _OutstandingAccountsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentInvoicesAsync = ref.watch(recentInvoicesStreamProvider);

    return recentInvoicesAsync.when(
      data: (invoices) {
        final outstandingAccounts = invoices.where((inv) => inv.creditBalanceAdded > 0).toList();
        
        if (outstandingAccounts.isEmpty) {
          return const Center(
            child: Text('No outstanding accounts found.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: outstandingAccounts.length,
          itemBuilder: (_, i) {
            final inv = outstandingAccounts[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv.customerName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(AppFormatters.currency(inv.creditBalanceAdded), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(inv.customerMobile, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Transaction Date: ${AppFormatters.date(inv.createdAt)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  if (inv.customerNotes != null && inv.customerNotes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Note: ${inv.customerNotes}', style: const TextStyle(color: AppColors.warning, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

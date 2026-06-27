import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/database/tables/sales_tables.dart';
import '../../core/providers.dart';
import '../../core/services/checkout_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/receipt_composer.dart';
import 'sales_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMode _paymentMode = PaymentMode.cash;
  final _customerNameCtrl = TextEditingController();
  final _customerMobileCtrl = TextEditingController();
  final _doctorNameCtrl = TextEditingController();
  final _doctorPlaceCtrl = TextEditingController();
  final _amountPaidCtrl = TextEditingController();
  final _customerNotesCtrl = TextEditingController();
  bool _loading = false;
  CheckoutResult? _result;
  List<CartItem>? _checkedOutItems;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerMobileCtrl.dispose();
    _doctorNameCtrl.dispose();
    _doctorPlaceCtrl.dispose();
    _amountPaidCtrl.dispose();
    _customerNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final total = cart.fold(0.0, (s, i) => s + i.lineTotal);
    final amountPaid = _amountPaidCtrl.text.trim().isEmpty ? total : (double.tryParse(_amountPaidCtrl.text) ?? total);
    final creditBalanceAdded = total - amountPaid;

    setState(() => _loading = true);
    try {
      final result =
          await ref.read(checkoutServiceProvider).processCheckout(
                items: cart,
                paymentMode: _paymentMode,
                customerName: _customerNameCtrl.text.trim().isEmpty ? 'Cash Customer' : _customerNameCtrl.text.trim(),
                customerMobile: _customerMobileCtrl.text.trim().isEmpty ? '0000000000' : _customerMobileCtrl.text.trim(),
                doctorName: _doctorNameCtrl.text.trim().isEmpty ? 'Self' : _doctorNameCtrl.text.trim(),
                doctorPlace: _doctorPlaceCtrl.text.trim().isEmpty ? 'Local' : _doctorPlaceCtrl.text.trim(),
                amountPaid: amountPaid,
                creditBalanceAdded: creditBalanceAdded > 0 ? creditBalanceAdded : 0,
                customerNotes: _customerNotesCtrl.text.trim().isEmpty ? null : _customerNotesCtrl.text.trim(),
              );

      final cartCopy = List<CartItem>.from(cart);
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        setState(() {
          _result = result;
          _checkedOutItems = cartCopy;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    if (_result == null || _checkedOutItems == null) return;
    
    final invoice = await ref.read(salesDaoProvider).getInvoiceById(_result!.invoiceId);
    if (invoice == null) return;

    final items = _checkedOutItems!.map((i) => ReceiptLineItem(
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: i.quantity,
          mrp: i.mrp,
          discountPercent: i.discountPercent,
          gstPercent: i.gstPercentage,
          lineTotal: i.lineTotal,
          composition: i.composition,
          alternativeName: i.alternativeName,
        )).toList();

    final text = ReceiptComposer.generateWhatsAppInvoice(
      invoice: invoice,
      items: items,
    );

    final phone = invoice.customerMobile.trim().isEmpty
        ? null
        : '91${invoice.customerMobile.trim().replaceAll(RegExp(r'[^0-9]'), '')}';

    final ok = await ReceiptComposer.launchWhatsApp(text: text, phone: phone);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('WhatsApp not available on this device'),
          backgroundColor: AppColors.warning));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = cart.fold(0.0, (s, i) => s + i.mrp * i.quantity);
    final totalDiscount = cart.fold(
        0.0, (s, i) => s + (i.mrp * i.quantity * i.discountPercent / 100));
    final totalGst = cart.fold(0.0, (s, i) => s + i.gstAmount);
    final total = cart.fold(0.0, (s, i) => s + i.lineTotal);

    final needsDoctor = cart.any((item) =>
        item.category == ProductCategory.scheduleH ||
        item.category == ProductCategory.scheduleH1);

    // ── Success state ────────────────────────────────────────
    if (_result != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Invoice Saved')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 56),
                ),
                const SizedBox(height: 20),
                Text(
                  AppFormatters.currency(_result!.total),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _result!.invoiceNumber,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _shareWhatsApp,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Send WhatsApp Receipt'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _result = null;
                      _checkedOutItems = null;
                    });
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: const Text('New Sale'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Checkout form ────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order summary
          _section(
            'Order Summary',
            Column(
              children: [
                ...cart.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  '${item.quantity} × ${AppFormatters.currency(item.mrp)}',
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.currency(item.lineTotal),
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 16),
                _totalsRow('Subtotal', subtotal, dimmed: true),
                if (totalDiscount > 0)
                  _totalsRow('Discount', -totalDiscount,
                      color: AppColors.success),
                _totalsRow('GST', totalGst, dimmed: true),
                const SizedBox(height: 4),
                _totalsRow('Total', total,
                    large: true, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer
          _section(
            'Patient & Doctor Info',
            Column(
              children: [
                TextField(
                  controller: _customerNameCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerMobileCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Mobile (for WhatsApp)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _doctorNameCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      labelText: needsDoctor ? 'Doctor Name (Required for Sch-H/H1)' : 'Doctor Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _doctorPlaceCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Clinic / Hospital Locality'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Note Book
          _section(
            'Payment & Note Book',
            Column(
              children: [
                TextField(
                  controller: _amountPaidCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      labelText: 'Amount Paid Now (₹)',
                      hintText: 'Leave empty if full amount is paid (${AppFormatters.currency(total)})'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerNotesCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Note Book Reminder / Comments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment mode
          _section(
            'Payment Mode',
            Wrap(
              spacing: 8,
              children: PaymentMode.values
                  .map((m) => _PaymentChip(
                        mode: m,
                        selected: _paymentMode == m,
                        onTap: () => setState(() => _paymentMode = m),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _loading ? null : _checkout,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : Text(
                    'Confirm Payment  •  ${AppFormatters.currency(total)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) => Column(
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
            child: child,
          ),
        ],
      );

  Widget _totalsRow(String label, double value,
      {bool dimmed = false, bool large = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: dimmed ? AppColors.textMuted : AppColors.textSecondary,
                  fontSize: large ? 15 : 13,
                  fontWeight:
                      large ? FontWeight.w700 : FontWeight.w400)),
          const Spacer(),
          Text(
            AppFormatters.currency(value.abs()),
            style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: large ? 18 : 13,
                fontWeight:
                    large ? FontWeight.w800 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final PaymentMode mode;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentChip(
      {required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (mode) {
      PaymentMode.cash => ('Cash', Icons.payments_outlined),
      PaymentMode.upi => ('UPI', Icons.phone_android_outlined),
      PaymentMode.credit => ('Credit', Icons.credit_score_outlined),
      PaymentMode.card => ('Card', Icons.credit_card_outlined),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.surfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

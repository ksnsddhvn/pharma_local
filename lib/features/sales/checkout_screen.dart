import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/database/tables/sales_tables.dart';
import '../../core/providers.dart';
import '../../core/services/checkout_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/receipt_composer.dart';
import '../../core/utils/pdf_invoice_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'new_sale_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMode _paymentMode = PaymentMode.cash;
  final _customerNameCtrl = TextEditingController();
  final _customerMobileCtrl = TextEditingController();
  final _customerPlaceCtrl = TextEditingController();
  final _doctorNameCtrl = TextEditingController();
  final _doctorPlaceCtrl = TextEditingController();
  final _amountPaidCtrl = TextEditingController();
  final _customerNotesCtrl = TextEditingController();
  
  final _customerNameNode = FocusNode();
  final _customerMobileNode = FocusNode();
  final _customerPlaceNode = FocusNode();
  final _doctorNameNode = FocusNode();
  final _doctorPlaceNode = FocusNode();
  final _amountPaidNode = FocusNode();
  final _customerNotesNode = FocusNode();
  bool _loading = false;
  CheckoutResult? _result;
  List<CartItem>? _checkedOutItems;
  Future<String?>? _receiptTextFuture;

  @override
  void initState() {
    super.initState();
    _amountPaidCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerMobileCtrl.dispose();
    _customerPlaceCtrl.dispose();
    _doctorNameCtrl.dispose();
    _doctorPlaceCtrl.dispose();
    _amountPaidCtrl.dispose();
    _customerNotesCtrl.dispose();
    _customerNameNode.dispose();
    _customerMobileNode.dispose();
    _customerPlaceNode.dispose();
    _doctorNameNode.dispose();
    _doctorPlaceNode.dispose();
    _amountPaidNode.dispose();
    _customerNotesNode.dispose();
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
                customerPlace: _customerPlaceCtrl.text.trim().isEmpty ? 'Kandukur' : _customerPlaceCtrl.text.trim(),
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
          _receiptTextFuture = _generateReceiptText();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: context.colors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _generateReceiptText() async {
    if (_result == null || _checkedOutItems == null) return null;
    
    final invoice = await ref.read(salesDaoProvider).getInvoiceById(_result!.invoiceId);
    if (invoice == null) return null;

    final items = _checkedOutItems!.map((i) => ReceiptLineItem(
          productName: i.productName,
          batchNumber: i.batchNumber,
          quantity: i.quantity,
          mrp: i.mrp,
          discountPercent: i.discountPercent,
          gstPercent: i.gstPercentage,
          lineTotal: i.lineTotal,
          hsnCode: i.hsnCode,
          packagingUnit: i.packagingUnit,
          alternativeName: i.alternativeName,
        )).toList();

    return ReceiptComposer.generateWhatsAppInvoice(
      invoice: invoice,
      items: items,
    );
  }

  Future<void> _shareWhatsApp() async {
    final text = await _receiptTextFuture;
    if (text == null) return;
    
    final invoice = await ref.read(salesDaoProvider).getInvoiceById(_result!.invoiceId);
    if (invoice == null) return;

    final phone = invoice.customerMobile.trim().isEmpty
        ? null
        : '91${invoice.customerMobile.trim().replaceAll(RegExp(r'[^0-9]'), '')}';

    final ok = await ReceiptComposer.launchWhatsApp(text: text, phone: phone);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('WhatsApp not available on this device'),
          backgroundColor: context.colors.warning));
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

    final needsDoctor = true; // Doctor name may be required for certain items, now default visible

    // ── Success state ────────────────────────────────────────
    if (_result != null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(title: Text('Invoice Saved')),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: FutureBuilder<String?>(
                future: _receiptTextFuture,
                builder: (context, snapshot) {
                  final receiptText = snapshot.data;
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.colors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_outline,
                            color: context.colors.success, size: 56),
                      ),
                      SizedBox(height: 20),
                      Text(
                        AppFormatters.currency(_result!.total),
                        style: TextStyle(
                            color: context.colors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _result!.invoiceNumber,
                        style: TextStyle(
                            color: context.colors.textSecondary, fontSize: 14),
                      ),
                      SizedBox(height: 24),
                      if (receiptText != null) ...[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.surfaceBorder),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                              receiptText,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Share.share(receiptText),
                                icon: Icon(Icons.share_outlined, size: 18),
                                label: Text('Share'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _shareWhatsApp,
                                icon: Icon(Icons.chat, size: 18),
                                label: Text('WhatsApp'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final invoiceId = _result!.invoiceId;
                              final invoice = await ref.read(salesDaoProvider).getInvoiceById(invoiceId);
                              if (invoice == null) return;
                              final items = (_checkedOutItems ?? []).map((i) => ReceiptLineItem(
                                productName: i.productName,
                                batchNumber: i.batchNumber,
                                quantity: i.quantity,
                                mrp: i.mrp,
                                discountPercent: i.discountPercent,
                                gstPercent: i.gstPercentage,
                                lineTotal: i.lineTotal,
                                hsnCode: i.hsnCode,
                                packagingUnit: i.packagingUnit,
                                alternativeName: i.alternativeName,
                              )).toList();
                              
                              await Printing.layoutPdf(
                                onLayout: (format) => PdfInvoiceGenerator.generate(invoice, items),
                                name: 'Invoice_${invoice.invoiceNumber}.pdf',
                              );
                            },
                            icon: Icon(Icons.print, size: 18),
                            label: Text('Print / PDF Receipt'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                      ] else ...[
                        Spacer(),
                      ],
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _result = null;
                            _checkedOutItems = null;
                            _receiptTextFuture = null;
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(48)),
                        child: Text('New Sale'),
                      ),
                    ],
                  );
                }
              ),
          ),
        ),
      );
    }

    // ── Checkout form ────────────────────────────────────────
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text('Checkout')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Order summary
          _section(
            'Order Summary',
            Column(
              children: [
                ...cart.map((item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.productName} (${item.packagingUnit})',
                                    style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  '${item.quantity} × ${AppFormatters.currency(item.mrp)}',
                                  style: TextStyle(
                                      color: context.colors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.currency(item.lineTotal),
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                Divider(height: 16),
                _totalsRow('Subtotal', subtotal, dimmed: true),
                if (totalDiscount > 0)
                  _totalsRow('Discount', -totalDiscount,
                      color: context.colors.success),
                _totalsRow('GST', totalGst, dimmed: true),
                SizedBox(height: 4),
                _totalsRow('Total', total,
                    large: true, color: context.colors.primary),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Customer
          _section(
            'Patient & Doctor Info',
            Column(
              children: [
                TextField(
                  controller: _customerNameCtrl,
                  focusNode: _customerNameNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _customerMobileNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(labelText: 'Patient Name'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _customerMobileCtrl,
                  focusNode: _customerMobileNode,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _customerPlaceNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(labelText: 'Mobile (for WhatsApp)'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _customerPlaceCtrl,
                  focusNode: _customerPlaceNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _doctorNameNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(labelText: 'Patient Place'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _doctorNameCtrl,
                  focusNode: _doctorNameNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _doctorPlaceNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                      labelText: needsDoctor ? 'Doctor Name (Required for Sch-H/H1)' : 'Doctor Name'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _doctorPlaceCtrl,
                  focusNode: _doctorPlaceNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _amountPaidNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(labelText: 'Clinic / Hospital Locality'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Payment Note Book
          _section(
            'Payment & Note Book',
            Column(
              children: [
                TextField(
                  controller: _amountPaidCtrl,
                  focusNode: _amountPaidNode,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _customerNotesNode.requestFocus(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                      labelText: 'Amount Paid Now (₹)',
                      hintText: 'Leave empty if full amount is paid (${AppFormatters.currency(total)})'),
                ),
                if (_amountPaidCtrl.text.isNotEmpty && (double.tryParse(_amountPaidCtrl.text) ?? total) < total)
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Balance to be paid later: ${AppFormatters.currency(total - (double.tryParse(_amountPaidCtrl.text) ?? 0))}',
                      style: TextStyle(color: context.colors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                SizedBox(height: 12),
                TextField(
                  controller: _customerNotesCtrl,
                  focusNode: _customerNotesNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(labelText: 'Note Book Reminder / Comments'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _checkout,
            style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(52)),
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(
                    'Confirm Payment  •  ${AppFormatters.currency(total)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) => Column(
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
            child: child,
          ),
        ],
      );

  Widget _totalsRow(String label, double value,
      {bool dimmed = false, bool large = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: dimmed ? context.colors.textMuted : context.colors.textSecondary,
                  fontSize: large ? 15 : 13,
                  fontWeight:
                      large ? FontWeight.w700 : FontWeight.w400)),
          Spacer(),
          Text(
            AppFormatters.currency(value.abs()),
            style: TextStyle(
                color: color ?? context.colors.textPrimary,
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
        duration: Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary.withValues(alpha: 0.15)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? context.colors.primary : context.colors.surfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected
                    ? context.colors.primary
                    : context.colors.textMuted,
                size: 18),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? context.colors.primary
                        : context.colors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

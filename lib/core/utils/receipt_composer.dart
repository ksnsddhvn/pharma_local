import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/tables/sales_tables.dart';

class ReceiptLineItem {
  final String productName;
  final String batchNumber;
  final int quantity;
  final double mrp;
  final double discountPercent;
  final double gstPercent;
  final double lineTotal;

  ReceiptLineItem({
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.discountPercent,
    required this.gstPercent,
    required this.lineTotal,
  });
}

/// Composes a plain-text GST-compliant invoice for WhatsApp sharing.
class ReceiptComposer {
  static final _currencyFmt = NumberFormat('#,##,##0.00', 'en_IN');
  static final _dateFmt = DateFormat('dd-MMM-yyyy hh:mm a');

  static String composeWhatsAppReceipt({
    required String invoiceNumber,
    required DateTime createdAt,
    required String? customerName,
    required List<ReceiptLineItem> items,
    required double subtotal,
    required double totalGst,
    required double totalDiscount,
    required double totalAmount,
    required PaymentMode paymentMode,
    String pharmacyName = 'PharmaLocal Medical Store',
    String? gstin,
  }) {
    final buf = StringBuffer();
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('🏥 *$pharmacyName*');
    if (gstin != null) buf.writeln('GSTIN: $gstin');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('Invoice No: *$invoiceNumber*');
    buf.writeln('Date: ${_dateFmt.format(createdAt)}');
    if (customerName != null && customerName.isNotEmpty) {
      buf.writeln('Patient: $customerName');
    }
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');

    for (final item in items) {
      buf.writeln('▸ ${item.productName}');
      buf.writeln(
          '  Batch: ${item.batchNumber} | Qty: ${item.quantity} × ₹${_currencyFmt.format(item.mrp)}');
      if (item.discountPercent > 0) {
        buf.writeln('  Disc: ${item.discountPercent.toStringAsFixed(0)}%');
      }
      buf.writeln(
          '  GST: ${item.gstPercent.toStringAsFixed(0)}% | Total: ₹${_currencyFmt.format(item.lineTotal)}');
    }

    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('Subtotal:   ₹${_currencyFmt.format(subtotal)}');
    if (totalDiscount > 0) {
      buf.writeln('Discount:  -₹${_currencyFmt.format(totalDiscount)}');
    }
    buf.writeln('GST:        ₹${_currencyFmt.format(totalGst)}');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('*TOTAL: ₹${_currencyFmt.format(totalAmount)}*');
    buf.writeln('Payment: ${_paymentLabel(paymentMode)}');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('Thank you! Stay healthy 💊');

    return buf.toString();
  }

  /// Opens WhatsApp with a pre-filled receipt message.
  /// [phone] should be in international format without '+', e.g. '919876543210'.
  static Future<bool> launchWhatsApp({
    required String text,
    String? phone,
  }) async {
    final encoded = Uri.encodeComponent(text);
    final url = phone != null && phone.isNotEmpty
        ? 'whatsapp://send?phone=$phone&text=$encoded'
        : 'whatsapp://send?text=$encoded';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    // Fallback to web.whatsapp.com for desktop
    final webUrl = Uri.parse(
        'https://web.whatsapp.com/send?text=$encoded');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  static String _paymentLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash 💵';
      case PaymentMode.upi:
        return 'UPI 📲';
      case PaymentMode.credit:
        return 'Credit 🏦';
      case PaymentMode.card:
        return 'Card 💳';
    }
  }
}

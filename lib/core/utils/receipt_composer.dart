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
  final String composition;
  final String? alternativeName;

  ReceiptLineItem({
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.discountPercent,
    required this.gstPercent,
    required this.lineTotal,
    this.composition = '',
    this.alternativeName,
  });
}

/// Composes a plain-text GST-compliant invoice for WhatsApp sharing.
class ReceiptComposer {
  static final _currencyFmt = NumberFormat('#,##,##0.00', 'en_IN');
  static final _dateFmt = DateFormat('dd-MMM-yyyy hh:mm a');

  static String composeWhatsAppReceipt({
    required String invoiceNumber,
    required DateTime createdAt,
    required String customerName,
    required String customerMobile,
    required String doctorName,
    required String doctorPlace,
    required List<ReceiptLineItem> items,
    required double subtotal,
    required double totalGst,
    required double totalDiscount,
    required double totalAmount,
    required double amountPaid,
    required double creditBalanceAdded,
    String? customerNotes,
    required PaymentMode paymentMode,
    String pharmacyName = 'PharmaLocal Medical Store',
    String? gstin,
  }) {
    final buf = StringBuffer();
    buf.writeln('--- RETAIL MEDICINE BILL ---');
    buf.writeln('Shop: $pharmacyName');
    buf.writeln('Patient: $customerName ($customerMobile)');
    buf.writeln('Dr: $doctorName ($doctorPlace)');
    buf.writeln('----------------------------');

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buf.writeln('${i + 1}. ${item.productName} (Batch: ${item.batchNumber}) x ${item.quantity} Tablets - ₹${_currencyFmt.format(item.lineTotal)}');
      if (item.composition.isNotEmpty) {
        buf.writeln('(Composition: ${item.composition})');
      }
      if (item.alternativeName != null && item.alternativeName!.isNotEmpty) {
        buf.writeln('*Alternative Available: ${item.alternativeName}*');
      }
    }

    buf.writeln('----------------------------');
    buf.writeln('Total Bill: ₹${_currencyFmt.format(totalAmount)}');
    
    if (creditBalanceAdded > 0) {
      buf.writeln('Payment Due: ₹${_currencyFmt.format(creditBalanceAdded)} (Logged to Note Book)');
    } else {
      buf.writeln('Amount Paid: ₹${_currencyFmt.format(amountPaid)}');
    }
    
    if (customerNotes != null && customerNotes.isNotEmpty) {
      buf.writeln('Note: $customerNotes');
    }

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

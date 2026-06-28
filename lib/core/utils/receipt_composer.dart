import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
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

  static String generateWhatsAppInvoice({
    required SalesInvoice invoice,
    required List<ReceiptLineItem> items,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("📝 *MEDICINE RECEIPT*");
    buffer.writeln("--------------------------------");
    buffer.writeln("👤 *Patient:* ${invoice.customerName} (${invoice.customerMobile})");
    buffer.writeln("👨⚕️ *Dr.:* ${invoice.doctorName} [${invoice.doctorPlace}]");
    buffer.writeln("--------------------------------");
    
    for (var item in items) {
      buffer.writeln("💊 ${item.productName} (${item.batchNumber})");
      buffer.writeln("   ${item.quantity} Tabs @ ₹${item.mrp}/tab = ₹${item.lineTotal.toStringAsFixed(2)}");
      if (item.alternativeName != null && item.alternativeName!.isNotEmpty) {
        buffer.writeln("*Alternative Available: ${item.alternativeName}*");
      }
    }
    
    buffer.writeln("--------------------------------");
    buffer.writeln("💵 *Total Bill:* ₹${invoice.totalAmount.toStringAsFixed(2)}");
    buffer.writeln("💰 *Paid:* ₹${invoice.amountPaid.toStringAsFixed(2)}");
    
    if (invoice.creditBalanceAdded > 0) {
      buffer.writeln("📌 *Pending Credit:* ₹${invoice.creditBalanceAdded.toStringAsFixed(2)}");
      if (invoice.customerNotes != null && invoice.customerNotes!.isNotEmpty) {
        buffer.writeln("📝 *Note:* ${invoice.customerNotes}");
      }
    }
    return buffer.toString();
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

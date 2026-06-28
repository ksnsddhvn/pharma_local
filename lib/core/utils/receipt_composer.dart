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
  final String hsnCode;
  final String packagingUnit;
  final String? alternativeName;

  ReceiptLineItem({
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.discountPercent,
    required this.gstPercent,
    required this.lineTotal,
    required this.hsnCode,
    this.packagingUnit = "10's Pack",
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
    buffer.writeln("==================================");
    buffer.writeln("       BILL OF SUPPLY");
    buffer.writeln("   RANGA MEDICAL STORES");
    buffer.writeln("==================================");
    buffer.writeln("📍 O.V. Road, KANDUKUR-523105");
    buffer.writeln("📞 Cell: 9849500749");
    buffer.writeln("📜 Lic No: 20-228/AP/PS(O)/1996/R");
    buffer.writeln("            21-228/AP/PS(O)/1996/R");
    buffer.writeln("🆔 GSTIN: 37AIRPD4121G1ZF");
    buffer.writeln("⚠️ Composition Taxable person, not eligible to collect tax on suppliers");
    buffer.writeln("----------------------------------");
    
    final dateStr = DateFormat('dd-MM-yyyy').format(invoice.createdAt);
    buffer.writeln("Bill No: #${invoice.id}          Date: $dateStr");
    buffer.writeln("Pt. Name: ${invoice.customerName}   Place: ${invoice.customerNotes ?? ''}");
    buffer.writeln("Dr. Name: ${invoice.doctorName}   Place: ${invoice.doctorPlace}");
    buffer.writeln("----------------------------------");
    buffer.writeln("PARTICULARS:");
    buffer.writeln("----------------------------------");
    
    for (var item in items) {
      buffer.writeln("💊 ${item.productName} (${item.packagingUnit})");
      buffer.writeln("   HSN: ${item.hsnCode} | Batch: ${item.batchNumber}");
      buffer.writeln("   Qty: ${item.quantity} | Amount: ₹${item.lineTotal.toStringAsFixed(2)}");
      buffer.writeln();
    }
    
    buffer.writeln("----------------------------------");
    buffer.writeln("💰 TOTAL AMOUNT: ₹${invoice.totalAmount.toStringAsFixed(2)}");
    buffer.writeln("----------------------------------");
    buffer.writeln("Notebook Status: ${_paymentLabel(invoice.paymentMode)}");
    buffer.writeln("Thank you! Visit again.");
    buffer.writeln("==================================");
    
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
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (_) {}

    // Fallback to web.whatsapp.com for desktop
    final webUrl = Uri.parse('https://web.whatsapp.com/send?text=$encoded');
    try {
      return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
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

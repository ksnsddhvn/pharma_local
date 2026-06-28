import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../database/app_database.dart';
import 'receipt_composer.dart';

class PdfInvoiceGenerator {
  static Future<Uint8List> generate(SalesInvoice invoice, List<ReceiptLineItem> items) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(invoice.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('SRI RANGA MEDICAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text('Invoice #: ${invoice.invoiceNumber}', style: const pw.TextStyle(fontSize: 10))),
              pw.Center(child: pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10))),
              if (invoice.customerName.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Customer: ${invoice.customerName}', style: const pw.TextStyle(fontSize: 10)),
                if (invoice.customerMobile.isNotEmpty)
                  pw.Text('Mobile: ${invoice.customerMobile}', style: const pw.TextStyle(fontSize: 10)),
              ],
              pw.Divider(thickness: 1, height: 16),
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 1, child: pw.Text('MRP', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(thickness: 1, height: 8),
              ...items.map((item) {
                final qtyStr = item.packagingUnit == 'Sheet' && (item.quantity % 10 == 0) // rough heuristic, better to just show qty
                    ? '${item.quantity}'
                    : '${item.quantity}'; // for pos receipt, simple quantity is fine
                
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.productName, style: const pw.TextStyle(fontSize: 9)),
                      pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(item.batchNumber, style: const pw.TextStyle(fontSize: 8))),
                          pw.Expanded(flex: 1, child: pw.Text(qtyStr, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Expanded(flex: 1, child: pw.Text(item.mrp.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                          pw.Expanded(flex: 2, child: pw.Text(item.lineTotal.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ],
                  )
                );
              }),
              pw.Divider(thickness: 1, height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('₹${invoice.totalAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (invoice.totalDiscount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('-₹${invoice.totalDiscount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              pw.Divider(thickness: 1, height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('₹${(invoice.totalAmount - invoice.totalDiscount).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text('Thank you for visiting!', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

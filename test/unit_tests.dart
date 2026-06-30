import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_local/core/utils/receipt_composer.dart';
import 'package:pharma_local/core/database/app_database.dart';
import 'package:pharma_local/core/database/tables/sales_tables.dart';

void main() {
  group('Tablet Fractional Math', () {
    test('calculate total strips correctly based on perStrip unit', () {
      int calculateTotalTablets(int qtyRequested, String packagingUnit) {
        int perStrip = 1;
        final unitStr = packagingUnit.toLowerCase();
        if (unitStr.endsWith("'s") || unitStr.endsWith("s")) {
          final numStr = unitStr.replaceAll(RegExp(r"[^0-9]"), "");
          perStrip = int.tryParse(numStr) ?? 1;
        }
        if (perStrip <= 0) perStrip = 1;
        return (qtyRequested / perStrip).ceil(); // Assuming we want strips
      }

      expect(calculateTotalTablets(10, "10's"), 1);
      expect(calculateTotalTablets(15, "10's"), 2);
      expect(calculateTotalTablets(30, "15's"), 2);
      expect(calculateTotalTablets(5, "10's"), 1);
      expect(calculateTotalTablets(1, "bottle"), 1);
    });
  });

  group('Supplier Credit Ledger Balances', () {
    test('calculate credit correctly', () {
      double calculateCreditBalance(double totalAmount, double paidAmount) {
        final diff = totalAmount - paidAmount;
        return diff > 0 ? diff : 0;
      }
      expect(calculateCreditBalance(500, 300), 200);
      expect(calculateCreditBalance(500, 500), 0);
      expect(calculateCreditBalance(500, 600), 0);
    });
  });

  group('Receipt Composer String Parsing', () {
    test('generate WhatsApp invoice correctly', () {
      final invoice = SalesInvoice(
        id: 123,
        invoiceNumber: 'PL-2026-001',
        customerName: 'Test Patient',
        customerMobile: '9876543210',
        customerPlace: 'Kandukur Town',
        doctorName: 'Dr. Smith',
        doctorPlace: 'City Hospital',
        createdAt: DateTime(2026, 6, 30, 10, 0),
        subtotal: 100,
        totalGst: 12,
        totalDiscount: 0,
        totalAmount: 112,
        amountPaid: 112,
        creditBalanceAdded: 0,
        customerNotes: 'Deliver by evening',
        paymentMode: PaymentMode.cash,
      );

      final items = [
        ReceiptLineItem(
          productName: 'Paracetamol',
          batchNumber: 'B123',
          quantity: 10,
          mrp: 10,
          discountPercent: 0,
          gstPercent: 12,
          lineTotal: 100,
          hsnCode: '3004',
        ),
      ];

      final text = ReceiptComposer.generateWhatsAppInvoice(
        invoice: invoice,
        items: items,
      );

      expect(text.contains('RANGA MEDICAL STORES'), isTrue);
      expect(text.contains('Address: O.V. Road, KANDUKUR-523105'), isTrue);
      expect(text.contains('Pt. Name: Test Patient'), isTrue);
      expect(text.contains('Place: Kandukur Town'), isTrue);
      expect(text.contains('Dr. Name: Dr. Smith'), isTrue);
      expect(text.contains('Place: City Hospital'), isTrue);
    });
  });
}

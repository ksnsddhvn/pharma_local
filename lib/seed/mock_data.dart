import 'package:drift/drift.dart';
import '../core/database/app_database.dart';
import '../core/database/tables/products_table.dart';
import '../core/database/tables/stock_batches_table.dart';
import '../core/database/tables/suppliers_table.dart';
import '../core/database/tables/supplier_ledgers_table.dart';
import '../core/database/tables/sales_tables.dart';

/// Seeds realistic Indian pharmacy mock data on first launch.
/// Safe to call multiple times — checks if data already exists.
class MockDataSeeder {
  final AppDatabase db;
  MockDataSeeder(this.db);

  Future<void> seedIfEmpty() async {
    final existing = await db.productsDao.getAllProducts();
    if (existing.isNotEmpty) return; // Already seeded

    await db.transaction(() async {
      final supplierIds = await _seedSuppliers();
      final productIds = await _seedProducts();
      await _seedBatches(productIds, supplierIds);
      await _seedSalesHistory(productIds);
    });
  }

  // ── 1. Suppliers ──────────────────────────────────────────────────────────
  Future<List<int>> _seedSuppliers() async {
    final suppliers = [
      ('Sun Pharma Distributors', '9876543210', '27AADCS1681Q1ZO', 'Rahul Sharma'),
      ('Cipla Agency Mumbai', '9823456789', '27AAACC7407L1ZL', 'Amit Patel'),
      ('Abbott India Ltd Dist.', '9845612370', '27AAAAD6888K1ZD', 'Priya Singh'),
      ('Alkem Laboratories Dist.', '9900112233', '27AAACA9999H1ZE', 'Vikram Joshi'),
      ('Lupin Ltd Pharma Depot', '9911223344', '27AAACL5555M1ZK', 'Rajeev Kumar'),
      ('Mankind Pharma Agency', '9922334455', '27AAACM4321J1ZP', 'Sanjay Verma'),
      ('Zydus Healthcare Dist.', '9933445566', '27AAACZ8765K1ZQ', 'Neha Gupta'),
      ('Dr. Reddy Labs Agency', '9944556677', '27AAACR2345L1ZR', 'Ramesh Rao'),
      ('Glenmark Pharma Depot', '9955667788', '27AAACG6789M1ZS', 'Kiran Shah'),
      ('Torrent Pharma Agency', '9966778899', '27AAACT3456N1ZT', 'Vijay Mehta'),
    ];

    final ids = <int>[];
    for (final s in suppliers) {
      final id = await db.suppliersDao.insertSupplier(
        SuppliersCompanion.insert(
          name: s.$1,
          phone: Value(s.$2),
          gstinNumber: Value(s.$3),
          contactPerson: Value(s.$4),
          currentBalance: const Value(0.0),
        ),
      );
      ids.add(id);
    }
    return ids;
  }

  // ── 2. Products ───────────────────────────────────────────────────────────
  Future<List<int>> _seedProducts() async {
    final products = [
      // name, composition, hsn, rack, threshold
      ('Paracetamol 500mg', 'Paracetamol IP 500mg', '3004', 'A-01', 50.0),
      ('Paracetamol 650mg', 'Paracetamol IP 650mg', '3004', 'A-02', 50.0),
      ('Ibuprofen 400mg', 'Ibuprofen IP 400mg', '3004', 'A-03', 30.0),
      ('Amoxicillin 500mg', 'Amoxicillin IP 500mg', '3004', 'D-01', 15.0),
      ('Vitamin C 500mg', 'Ascorbic Acid IP 500mg', '3006', 'F-01', 30.0),
    ];

    final ids = <int>[];
    for (final p in products) {
      final id = await db.productsDao.insertProduct(
        ProductsCompanion.insert(
          name: p.$1,
          composition: p.$2,
          hsnCode: Value(p.$3),
          categoryId: const Value(null),
          rackLocation: Value(p.$4),
          minStockThreshold: Value(p.$5.toInt()),
        ),
      );
      ids.add(id);
    }
    return ids;
  }

  // ── 3. Stock Batches ──────────────────────────────────────────────────────
  Future<void> _seedBatches(
      List<int> productIds, List<int> supplierIds) async {
    // GST rates by product index (0-based)
    final gstRates = {
      0: 5.0, 1: 5.0, 2: 5.0, 3: 5.0, 4: 5.0, 5: 5.0, // OTC basic
      30: 12.0, 31: 12.0, 32: 12.0, 33: 12.0, 34: 12.0, // Vitamins
    };
    double gstFor(int i) => gstRates[i] ?? 12.0;

    final now = DateTime.now();
    final batches = <(int, String, DateTime, double, double, int)>[
      // (productIndex, batchNo, expiry, mrp, purchaseRate, qty)
      (0, 'PC-2024-001', now.add(const Duration(days: 540)), 3.50, 2.10, 500),
      (0, 'PC-2024-002', now.add(const Duration(days: 180)), 3.50, 2.10, 200),
      (0, 'PC-2025-001', now.add(const Duration(days: 25)), 3.50, 2.10, 50),  // near expiry
      (1, 'PC6-2024-001', now.add(const Duration(days: 480)), 4.20, 2.50, 300),
      (2, 'IB-2024-001', now.add(const Duration(days: 600)), 8.50, 5.10, 200),
      (2, 'IB-2024-002', now.add(const Duration(days: 45)), 8.50, 5.10, 30),  // near expiry
      (3, 'AS-2024-001', now.add(const Duration(days: 720)), 2.80, 1.60, 400),
      (4, 'CT-2024-001', now.add(const Duration(days: 365)), 5.20, 3.10, 150),
      (5, 'LC-2024-001', now.add(const Duration(days: 400)), 6.80, 4.00, 120),
      (6, 'PZ-2024-001', now.add(const Duration(days: 550)), 18.50, 11.00, 100),
      (6, 'PZ-2024-002', now.add(const Duration(days: 20)), 18.50, 11.00, 40),  // near expiry
      (7, 'OM-2024-001', now.add(const Duration(days: 500)), 12.00, 7.20, 100),
      (8, 'MF-2024-001', now.add(const Duration(days: 520)), 4.50, 2.70, 200),
      (8, 'MF-2024-002', now.add(const Duration(days: 380)), 4.50, 2.70, 150),
      (9, 'MF1-2024-001', now.add(const Duration(days: 450)), 7.00, 4.20, 100),
      (10, 'GL1-2024-001', now.add(const Duration(days: 400)), 15.00, 9.00, 80),
      (11, 'GL2-2024-001', now.add(const Duration(days: 420)), 22.00, 13.20, 80),
      (12, 'AT10-2024-001', now.add(const Duration(days: 600)), 12.00, 7.20, 90),
      (13, 'AT20-2024-001', now.add(const Duration(days: 580)), 18.00, 10.80, 80),
      (14, 'AM5-2024-001', now.add(const Duration(days: 650)), 14.00, 8.40, 70),
      (15, 'TE40-2024-001', now.add(const Duration(days: 500)), 18.50, 11.10, 70),
      (16, 'TE80-2024-001', now.add(const Duration(days: 520)), 25.00, 15.00, 50),
      (17, 'LO-2024-001', now.add(const Duration(days: 480)), 20.00, 12.00, 60),
      (18, 'AX-2024-001', now.add(const Duration(days: 400)), 12.00, 7.20, 80),
      (19, 'AZ-2024-001', now.add(const Duration(days: 360)), 48.00, 28.80, 60),
      (20, 'CP-2024-001', now.add(const Duration(days: 420)), 14.00, 8.40, 60),
      (21, 'CF-2024-001', now.add(const Duration(days: 380)), 35.00, 21.00, 50),
      (22, 'MN-2024-001', now.add(const Duration(days: 440)), 8.00, 4.80, 100),
      (23, 'DX-2024-001', now.add(const Duration(days: 350)), 22.00, 13.20, 50),
      (24, 'DC-2024-001', now.add(const Duration(days: 500)), 10.00, 6.00, 80),
      (25, 'TR-2024-001', now.add(const Duration(days: 480)), 18.00, 10.80, 40),
      // Low stock items for shortbook testing
      (26, 'AX025-2024-001', now.add(const Duration(days: 600)), 12.00, 7.20, 3),
      (27, 'AX05-2024-001', now.add(const Duration(days: 580)), 18.00, 10.80, 2),
      (28, 'CL-2024-001', now.add(const Duration(days: 560)), 22.00, 13.20, 1),
      (29, 'ZP-2024-001', now.add(const Duration(days: 540)), 28.00, 16.80, 0), // out of stock
      (30, 'VC-2024-001', now.add(const Duration(days: 400)), 8.00, 4.80, 60),
      (31, 'VD-2024-001', now.add(const Duration(days: 380)), 45.00, 27.00, 40),
      (32, 'CA-2024-001', now.add(const Duration(days: 420)), 18.00, 10.80, 50),
      (33, 'MV-2024-001', now.add(const Duration(days: 360)), 28.00, 16.80, 40),
      (34, 'OR-2024-001', now.add(const Duration(days: 300)), 6.00, 3.60, 100),
      (35, 'RN-2024-001', now.add(const Duration(days: 480)), 8.00, 4.80, 80),
      (36, 'DP-2024-001', now.add(const Duration(days: 460)), 12.00, 7.20, 60),
      (37, 'ON-2024-001', now.add(const Duration(days: 440)), 22.00, 13.20, 40),
      (38, 'ML-2024-001', now.add(const Duration(days: 420)), 28.00, 16.80, 40),
      (39, 'SB-2024-001', now.add(const Duration(days: 400)), 180.00, 108.00, 15),
      (40, 'BD-2024-001', now.add(const Duration(days: 380)), 380.00, 228.00, 12),
      (41, 'IN-2024-001', now.add(const Duration(days: 60)), 580.00, 348.00, 8),  // near expiry
      (42, 'MT-2024-001', now.add(const Duration(days: 480)), 45.00, 27.00, 20),
      (43, 'LT50-2024-001', now.add(const Duration(days: 520)), 28.00, 16.80, 60),
      (44, 'LT100-2024-001', now.add(const Duration(days: 500)), 42.00, 25.20, 50),
      (45, 'PD-2024-001', now.add(const Duration(days: 400)), 18.00, 10.80, 40),
      (46, 'HC-2024-001', now.add(const Duration(days: 380)), 45.00, 27.00, 25),
      (47, 'BT-2024-001', now.add(const Duration(days: 360)), 68.00, 40.80, 20),
      (48, 'AF-2024-001', now.add(const Duration(days: 420)), 38.00, 22.80, 20),
      (49, 'NE-2024-001', now.add(const Duration(days: 400)), 28.00, 16.80, 15),
      (50, 'HFW-2024-001', now.add(const Duration(days: 540)), 150.00, 0.0, 20),
      (51, 'NBL-2024-001', now.add(const Duration(days: 540)), 299.00, 0.0, 15),
      (52, 'LSS-2024-001', now.add(const Duration(days: 540)), 350.00, 0.0, 10),
    ];

    for (final b in batches) {
      final pidx = b.$1;
      if (pidx >= productIds.length) continue;
      await db.stockBatchesDao.insertBatch(
        StockBatchesCompanion.insert(
          productId: productIds[pidx],
          batchNumber: b.$2,
          expiryDate: b.$3,
          mrp: b.$4,
          purchaseRate: b.$5,
          gstPercentage: Value(gstFor(pidx)),
          currentStock: Value(b.$6),
          isOpeningStock: Value(b.$5 == 0.0),
        ),
      );
    }

    // Seed a few supplier ledger entries (purchases)
    final purchaseData = [
      (0, 1, 12500.0, 'INV-SUN-2024-001'),
      (1, 2, 8200.0, 'INV-CIP-2024-001'),
      (2, 3, 5400.0, 'INV-ABT-2024-001'),
      (3, 4, 7800.0, 'INV-ALK-2024-001'),
      (4, 5, 9200.0, 'INV-LUP-2024-001'),
    ];

    for (final p in purchaseData) {
      final supplierId = supplierIds[p.$1];
      await db.supplierLedgerDao.insertEntry(
        SupplierLedgersCompanion.insert(
          supplierId: supplierId,
          transactionType: LedgerTxType.creditPurchase,
          amount: p.$3,
          balanceAfter: p.$3,
          invoiceNumber: Value(p.$4),
          referenceNote: const Value('Stock Purchase'),
        ),
      );
      await db.suppliersDao.updateBalance(supplierId, p.$3);
    }

    // Partial payments
    await db.supplierLedgerDao.insertEntry(
      SupplierLedgersCompanion.insert(
        supplierId: supplierIds[0],
        transactionType: LedgerTxType.cashPaid,
        amount: 5000.0,
        balanceAfter: 7500.0,
        referenceNote: const Value('Cash payment 15 Jun'),
      ),
    );
    await db.suppliersDao.updateBalance(supplierIds[0], 7500.0);

    await db.supplierLedgerDao.insertEntry(
      SupplierLedgersCompanion.insert(
        supplierId: supplierIds[1],
        transactionType: LedgerTxType.upiPaid,
        amount: 8200.0,
        balanceAfter: 0.0,
        referenceNote: const Value('UPI UTR: 4231897654321'),
      ),
    );
    await db.suppliersDao.updateBalance(supplierIds[1], 0.0);
  }

  // ── 4. Sales History ─────────────────────────────────────────────────────
  Future<void> _seedSalesHistory(List<int> productIds) async {
    final now = DateTime.now();

    final creditCustomers = [
      ('Sharma ji', '9876543210'),
      ('Verma ji', '9911223344'),
      ('Gupta ji', '9922334455'),
      ('Mishra ji', '9933445566'),
      ('Ramesh Kumar', '9823456789'),
      ('Suresh Singh', '9845612370'),
      ('Arun Patel', '9900112233'),
    ];

    // 30 sample invoices over the past 30 days
    for (var day = 0; day < 30; day++) {
      final saleDate = now.subtract(Duration(days: day));
      final numSales = (day % 4) + 1;

      for (var s = 0; s < numSales; s++) {
        final pidx = (day * 3 + s) % productIds.length;
        const qty = 2;
        const mrp = 12.0;
        const gst = 12.0;
        final lineTotal = mrp * qty;

        final isCredit = (day * 3 + s) % 5 == 0;
        final mode = isCredit
            ? PaymentMode.credit
            : ((day * 3 + s) % 5 == 1 ? PaymentMode.upi : PaymentMode.cash);

        String customerName = 'Cash Customer';
        String customerMobile = '0000000000';
        double amountPaid = lineTotal;
        double creditBalanceAdded = 0.0;
        String? notes;

        if (mode == PaymentMode.credit) {
          final custIdx = (day * 3 + s) % creditCustomers.length;
          customerName = creditCustomers[custIdx].$1;
          customerMobile = creditCustomers[custIdx].$2;
          amountPaid = (lineTotal * 0.3).roundToDouble();
          creditBalanceAdded = lineTotal - amountPaid;
          notes = 'Udhaar balance, will pay next month';
        } else if (mode == PaymentMode.upi) {
          customerName = 'UPI Customer';
          amountPaid = lineTotal;
          creditBalanceAdded = 0.0;
        }

        await db.salesDao.createInvoiceWithItems(
          SalesInvoicesCompanion.insert(
            invoiceNumber: 'PL-${saleDate.year}-${(day * 10 + s).toString().padLeft(4, '0')}',
            createdAt: Value(saleDate),
            customerName: customerName,
            customerMobile: customerMobile,
            subtotal: lineTotal,
            totalGst: lineTotal * gst / (100 + gst),
            totalDiscount: const Value(0.0),
            totalAmount: lineTotal,
            paymentMode: Value(mode),
            amountPaid: Value(amountPaid),
            creditBalanceAdded: Value(creditBalanceAdded),
            customerNotes: Value(notes),
            doctorName: Value(pidx >= 18 && pidx <= 29 ? 'Dr. R. K. Gupta' : 'Self'),
            doctorPlace: const Value('Local'),
          ),
          [
            SalesInvoiceItemsCompanion.insert(
              invoiceId: 0,
              batchId: 1,
              productId: productIds[pidx],
              productName: 'Sample Product',
              batchNumber: 'SEED-001',
              totalTabletsSold: Value(qty),
              mrpPerTablet: Value(mrp),
              gstPercentage: gst,
              discountPercent: const Value(0.0),
              lineTotal: lineTotal,
            ),
          ],
        );
      }
    }
  }
}

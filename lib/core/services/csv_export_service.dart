import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_local/core/database/app_database.dart';
import 'package:pharma_local/core/providers.dart';

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  final db = ref.read(databaseProvider);
  return CsvExportService(db);
});

class CsvExportService {
  final AppDatabase db;
  CsvExportService(this.db);

  Future<String> exportToCsvZip() async {
    final archive = Archive();

    // 1. Products
    final products = await db.select(db.products).get();
    final productRows = [
      ['ID', 'Name', 'Type', 'Packaging Unit', 'HSN Code', 'Deleted'],
      ...products.map((p) => [
            p.id,
            p.name,
            p.productType ?? '',
            p.packagingUnit ?? '',
            p.hsnCode ?? '',
            p.isDeleted ?? false
          ])
    ];
    _addCsvToArchive(archive, 'products.csv', productRows);

    // 2. Stock Batches
    final batches = await db.select(db.stockBatches).get();
    final batchRows = [
      ['ID', 'Product ID', 'Batch Number', 'Expiry Date', 'MRP', 'Purchase Rate', 'GST %', 'Current Stock', 'Created At'],
      ...batches.map((b) => [
            b.id,
            b.productId,
            b.batchNumber,
            b.expiryDate.toIso8601String(),
            b.mrp,
            b.purchaseRate,
            b.gstPercentage,
            b.currentStock,
            b.createdAt.toIso8601String()
          ])
    ];
    _addCsvToArchive(archive, 'stock_batches.csv', batchRows);

    // 3. Sales Invoices
    final invoices = await db.select(db.salesInvoices).get();
    final invoiceRows = [
      ['ID', 'Customer Name', 'Customer Mobile', 'Total Amount', 'Created At'],
      ...invoices.map((i) => [
            i.id,
            i.customerName,
            i.customerMobile,
            i.totalAmount,
            i.createdAt.toIso8601String()
          ])
    ];
    _addCsvToArchive(archive, 'sales_invoices.csv', invoiceRows);

    // 4. Sales Items
    final saleItems = await db.select(db.salesInvoiceItems).get();
    final saleItemRows = [
      ['ID', 'Invoice ID', 'Product ID', 'Batch ID', 'Quantity', 'Unit Price', 'Total Price'],
      ...saleItems.map((si) => [
            si.id,
            si.invoiceId,
            si.productId,
            si.batchId,
            si.totalTabletsSold,
            si.mrpPerTablet,
            si.lineTotal
          ])
    ];
    _addCsvToArchive(archive, 'sales_items.csv', saleItemRows);

    // Encode to ZIP
    final zipBytes = ZipEncoder().encode(archive);
    
    final docsDir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final outFile = File(path.join(docsDir.path, 'pharma_csv_export_$ts.zip'));
    
    await outFile.writeAsBytes(zipBytes!);
    return outFile.path;
  }

  void _addCsvToArchive(Archive archive, String filename, List<List<dynamic>> rows) {
    final csvString = Csv().encode(rows);
    final bytes = csvString.codeUnits;
    archive.addFile(ArchiveFile(filename, bytes.length, bytes));
  }
}

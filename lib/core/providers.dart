import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/app_database.dart';
import 'database/daos/stock_batches_dao.dart';
import 'services/inventory_service.dart';
import 'services/checkout_service.dart';
import 'services/supplier_service.dart';
import 'services/shortbook_service.dart';
import 'services/backup_service.dart';
import 'services/opening_stock_service.dart';

// ── Database singleton ──────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── DAOs ────────────────────────────────────────────────────────────────────
final productsDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).productsDao);

final stockBatchesDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).stockBatchesDao);

final suppliersDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).suppliersDao);

final supplierLedgerDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).supplierLedgerDao);

final salesDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).salesDao);

// ── Services ────────────────────────────────────────────────────────────────
final inventoryServiceProvider = Provider(
    (ref) => InventoryService(ref.watch(databaseProvider)));

final checkoutServiceProvider = Provider(
    (ref) => CheckoutService(ref.watch(databaseProvider)));

final supplierServiceProvider = Provider(
    (ref) => SupplierService(ref.watch(databaseProvider)));

final shortbookServiceProvider = Provider(
    (ref) => ShortbookService(ref.watch(databaseProvider)));

final openingStockServiceProvider = Provider(
    (ref) => OpeningStockService(ref.watch(databaseProvider)));

final backupServiceProvider = Provider((_) => BackupService());

// ── Stream Providers ─────────────────────────────────────────────────────────
final allProductsStreamProvider = StreamProvider(
    (ref) => ref.watch(productsDaoProvider).watchAllProducts());

final allSuppliersStreamProvider = StreamProvider(
    (ref) => ref.watch(suppliersDaoProvider).watchAllSuppliers());

final recentInvoicesStreamProvider = StreamProvider(
    (ref) => ref.watch(salesDaoProvider).watchRecentInvoices());

final batchesForProductProvider = StreamProvider.family<List<StockBatch>, int>(
    (ref, productId) => ref.watch(stockBatchesDaoProvider).watchBatchesForProduct(productId));

// ── Dashboard Data ────────────────────────────────────────────────────────────
final todaysSalesTotalProvider = FutureProvider(
    (ref) => ref.watch(salesDaoProvider).getTodaysSalesTotal());

final shortbookCountProvider = FutureProvider((ref) async {
  final items = await ref.watch(shortbookServiceProvider).getShortbookItems();
  return items.length;
});

final shortbookItemsProvider = FutureProvider((ref) => 
    ref.watch(shortbookServiceProvider).getShortbookItems());

final expiringBatchesCountProvider = FutureProvider((ref) async {
  final batches =
      await ref.watch(stockBatchesDaoProvider).getExpiringBatches(30);
  return batches.length;
});

final expiringBatchesProvider = FutureProvider.family<List<BatchWithProduct>, int>((ref, days) => 
    ref.watch(stockBatchesDaoProvider).getExpiringBatches(days));

final weeklySalesProvider = FutureProvider(
    (ref) => ref.watch(salesDaoProvider).getDailySalesTotals(7));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/app_database.dart';
import 'services/inventory_service.dart';
import 'services/checkout_service.dart';
import 'services/supplier_service.dart';
import 'services/shortbook_service.dart';
import 'services/backup_service.dart';

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

final backupServiceProvider = Provider((_) => BackupService());

// ── Stream Providers ─────────────────────────────────────────────────────────
final allProductsStreamProvider = StreamProvider(
    (ref) => ref.watch(productsDaoProvider).watchAllProducts());

final allSuppliersStreamProvider = StreamProvider(
    (ref) => ref.watch(suppliersDaoProvider).watchAllSuppliers());

final recentInvoicesStreamProvider = StreamProvider(
    (ref) => ref.watch(salesDaoProvider).watchRecentInvoices());

// ── Dashboard Data ────────────────────────────────────────────────────────────
final todaysSalesTotalProvider = FutureProvider(
    (ref) => ref.watch(salesDaoProvider).getTodaysSalesTotal());

final shortbookCountProvider = FutureProvider((ref) async {
  final items = await ref.watch(shortbookServiceProvider).getShortbookItems();
  return items.length;
});

final expiringBatchesCountProvider = FutureProvider((ref) async {
  final batches =
      await ref.watch(stockBatchesDaoProvider).getExpiringBatches(30);
  return batches.length;
});

final weeklySalesProvider = FutureProvider(
    (ref) => ref.watch(salesDaoProvider).getDailySalesTotals(7));

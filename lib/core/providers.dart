import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/app_database.dart';
import 'database/daos/stock_batches_dao.dart';
import 'services/inventory_service.dart';
import 'database/daos/sales_dao.dart';
import 'services/checkout_service.dart';
import 'services/supplier_service.dart';
import 'services/shortbook_service.dart';
import 'services/backup_service.dart';
import 'services/opening_stock_service.dart';

// --- Shared Preferences ---
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Override in main()
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  
  ThemeModeNotifier(this.prefs) : super(_loadThemeMode(prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final val = prefs.getString('theme_mode') ?? 'light';
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    prefs.setString('theme_mode', mode.name);
  }
}

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

final supplierLedgerDaoProvider = Provider((ref) => ref.watch(databaseProvider).supplierLedgerDao);
final inventoryAdjustmentDaoProvider = Provider((ref) => ref.watch(databaseProvider).inventoryAdjustmentDao);

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
final todaysSalesTotalProvider = StreamProvider(
    (ref) => ref.watch(salesDaoProvider).watchTodaysSalesTotal());

final shortbookCountProvider = StreamProvider((ref) {
  return ref.watch(shortbookServiceProvider).watchShortbookItems().map((items) => items.length);
});

final shortbookItemsProvider = StreamProvider((ref) => 
    ref.watch(shortbookServiceProvider).watchShortbookItems());

final expiringBatchesCountProvider = StreamProvider((ref) {
  return ref.watch(stockBatchesDaoProvider).watchExpiringBatches(30).map((batches) => batches.length);
});

final expiringBatchesProvider = StreamProvider.family<List<BatchWithProduct>, int>((ref, days) => 
    ref.watch(stockBatchesDaoProvider).watchExpiringBatches(days));

final weeklySalesProvider = StreamProvider(
    (ref) => ref.watch(salesDaoProvider).watchDailySalesTotals(7));

final paymentModeBreakdownProvider = StreamProvider(
    (ref) => ref.watch(salesDaoProvider).watchPaymentModeBreakdown(30));

final profitLossStatsProvider = StreamProvider.family<ProfitLossStats, int>((ref, days) {
  final from = DateTime.now().subtract(Duration(days: days));
  return ref.watch(salesDaoProvider).watchProfitLossStats(from, DateTime.now());
});

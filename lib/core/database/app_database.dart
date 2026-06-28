import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/products_table.dart';
import 'tables/product_categories_table.dart';
import 'tables/security_settings_table.dart';
import 'tables/stock_batches_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/supplier_ledgers_table.dart';
import 'tables/sales_tables.dart';
import 'tables/inventory_adjustments_table.dart';

import 'daos/products_dao.dart';
import 'daos/stock_batches_dao.dart';
import 'daos/suppliers_dao.dart';
import 'daos/supplier_ledger_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/inventory_adjustment_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ProductCategories,
    SecuritySettings,
    Products,
    StockBatches,
    Suppliers,
    SupplierLedgers,
    SalesInvoices,
    SalesInvoiceItems,
    InventoryAdjustments,
  ],
  daos: [
    ProductsDao,
    StockBatchesDao,
    SuppliersDao,
    SupplierLedgerDao,
    SalesDao,
    InventoryAdjustmentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Create performance indexes
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_products_name ON products (name COLLATE NOCASE)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_batches_expiry ON stock_batches (expiry_date)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_batches_product ON stock_batches (product_id)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_ledger_supplier ON supplier_ledgers (supplier_id)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_invoices_date ON sales_invoices (created_at)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 5) {
            // Drop all tables and recreate to apply massive dev schema changes & re-seed
            for (final table in allTables) {
              await m.drop(table);
            }
            await m.createAll();
          } else if (from == 5) {
            // Recreate products table to apply column removals (composition, rackLocation, minStockThreshold)
            await m.alterTable(TableMigration(products));
          }
          if (from < 7) {
            await m.addColumn(products, products.productType);
          }
          if (from < 8) {
            await m.createTable(inventoryAdjustments);
          }
          if (from < 9) {
            await m.addColumn(products, products.isDeleted);
            await m.addColumn(productCategories, productCategories.isDeleted);
            await m.addColumn(suppliers, suppliers.isDeleted);
          }
          if (from < 10) {
            await m.addColumn(stockBatches, stockBatches.isDeleted);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'pharma_local');
}

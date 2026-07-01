import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/product_categories_table.dart';
import '../tables/stock_batches_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products, ProductCategories, StockBatches])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Stream<List<Product>> watchAllProducts() =>
      (select(products)..where((p) => p.isDeleted.equals(false))..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

  Stream<List<Product>> watchProductsByCategory(int categoryId) =>
      (select(products)..where((p) => p.isDeleted.equals(false) & p.categoryId.equals(categoryId))..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

  Future<List<Product>> getAllProducts() =>
      (select(products)..where((p) => p.isDeleted.equals(false))..orderBy([(p) => OrderingTerm.asc(p.name)])).get();

  /// Exact or prefix search for the search screen.
  Future<List<Product>> searchProducts(String query) {
    final q = query.toLowerCase().trim();
    return (select(products)
          ..where(
            (p) =>
                p.isDeleted.equals(false) & (
                p.name.lower().contains(q) |
                p.hsnCode.lower().contains(q)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)])
          ..limit(100))
        .get();
  }

  Stream<List<Product>> watchProductsBySupplier(int supplierId) {
    final query = select(products).join([
      innerJoin(stockBatches, stockBatches.productId.equalsExp(products.id)),
    ])..where(products.isDeleted.equals(false) & stockBatches.supplierId.equals(supplierId));

    return query.watch().map((rows) {
      final uniqueProducts = <int, Product>{};
      for (final row in rows) {
        final p = row.readTable(products);
        uniqueProducts[p.id] = p;
      }
      final list = uniqueProducts.values.toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }



  Future<Product?> getProductById(int id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProduct(ProductsCompanion entry) =>
      into(products).insert(entry);

  Future<bool> updateProduct(ProductsCompanion entry) =>
      update(products).replace(entry);

  Future<int> deleteProduct(int id) =>
      (update(products)..where((p) => p.id.equals(id))).write(ProductsCompanion(isDeleted: Value(true)));

  Stream<ProductDetailedPayload> watchProductCompleteDetails(int productId) {
    // Join the product profile row with its corresponding category and batch rows
    final query = select(products).join([
      leftOuterJoin(productCategories, productCategories.id.equalsExp(products.categoryId)),
      innerJoin(stockBatches, stockBatches.productId.equalsExp(products.id)),
    ])..where(products.id.equals(productId));

    return query.watch().map((rows) {
      if (rows.isEmpty) throw Exception("Product context not found");
      
      // Read the master item details from the first available row match
      final firstRow = rows.first;
      final productRecord = firstRow.readTable(products);
      final categoryRecord = firstRow.readTableOrNull(productCategories);
      
      // Extract all batch entries associated with this product ID
      final batchList = rows.map((row) => row.readTable(stockBatches)).toList();
      
      return ProductDetailedPayload(
        product: productRecord,
        category: categoryRecord,
        batches: batchList,
      );
    });
  }

  Stream<List<ProductCategory>> watchAllCategories() =>
      (select(productCategories)..where((c) => c.isDeleted.equals(false))..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();

  Stream<List<ProductDetailedPayload>> watchLowStockProducts() {
    final query = select(products).join([
      leftOuterJoin(productCategories, productCategories.id.equalsExp(products.categoryId)),
      innerJoin(stockBatches, stockBatches.productId.equalsExp(products.id)),
    ])..where(products.isDeleted.equals(false));

    return query.watch().map((rows) {
      final map = <int, ProductDetailedPayload>{};
      for (final row in rows) {
        final product = row.readTable(products);
        final batch = row.readTable(stockBatches);
        if (!map.containsKey(product.id)) {
           map[product.id] = ProductDetailedPayload(
             product: product,
             category: row.readTableOrNull(productCategories),
             batches: [],
           );
        }
        map[product.id]!.batches.add(batch);
      }
      
      final lowStockList = <ProductDetailedPayload>[];
      for (final payload in map.values) {
         final totalStock = payload.batches.fold<int>(0, (sum, b) => sum + b.currentStock);
         if (totalStock < payload.product.minStockThreshold) {
            lowStockList.add(payload);
         }
      }
      return lowStockList;
    });
  }

  Stream<List<ProductDetailedPayload>> watchShortbookFeed() {
    final query = select(products).join([
      leftOuterJoin(productCategories, productCategories.id.equalsExp(products.categoryId)),
      innerJoin(stockBatches, stockBatches.productId.equalsExp(products.id)),
    ])..where(products.isDeleted.equals(false) & stockBatches.currentStock.equals(0));

    return query.watch().map((rows) {
      final map = <int, ProductDetailedPayload>{};
      for (final row in rows) {
        final product = row.readTable(products);
        final batch = row.readTable(stockBatches);
        if (!map.containsKey(product.id)) {
           map[product.id] = ProductDetailedPayload(
             product: product,
             category: row.readTableOrNull(productCategories),
             batches: [],
           );
        }
        map[product.id]!.batches.add(batch);
      }
      return map.values.toList();
    });
  }
}

// English payload helper structure for UI cards
class ProductDetailedPayload {
  final Product product;
  final ProductCategory? category;
  final List<StockBatch> batches;

  ProductDetailedPayload({
    required this.product,
    this.category,
    required this.batches,
  });
}

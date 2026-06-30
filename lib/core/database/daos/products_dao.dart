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

  /// All products ordered by name.
  Stream<List<Product>> watchAllProducts() =>
      (select(products)..where((p) => p.isDeleted.equals(false))..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

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

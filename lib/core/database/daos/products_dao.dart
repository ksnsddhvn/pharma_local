import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
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
}

import '../database/app_database.dart';
import '../database/tables/products_table.dart';

/// A product that is below its minimum stock threshold.
class ShortbookItem {
  final Product product;
  final int currentStock;
  final double threshold;
  ShortbookItem(
      {required this.product,
      required this.currentStock,
      required this.threshold});
}

/// Returns products that need to be reordered.
class ShortbookService {
  final AppDatabase db;
  ShortbookService(this.db);

  Future<List<ShortbookItem>> getShortbookItems() async {
    final allProducts = await db.productsDao.getAllProducts();
    final stockMap = await db.stockBatchesDao.getTotalStockPerProduct();

    final result = <ShortbookItem>[];
    for (final product in allProducts) {
      final stock = stockMap[product.id] ?? 0;
      if (stock < product.minStockThreshold) {
        result.add(ShortbookItem(
          product: product,
          currentStock: stock,
          threshold: product.minStockThreshold.toDouble(),
        ));
      }
    }

    // Sort by most critical first (lowest stock ratio)
    result.sort((a, b) {
      final ratioA = a.threshold > 0 ? a.currentStock / a.threshold : 0.0;
      final ratioB = b.threshold > 0 ? b.currentStock / b.threshold : 0.0;
      return ratioA.compareTo(ratioB);
    });

    return result;
  }
}

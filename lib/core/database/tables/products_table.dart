import 'package:drift/drift.dart';
import 'product_categories_table.dart';

@DataClassName('Product')
@TableIndex(name: 'idx_product_composition', columns: {#composition})
@TableIndex(name: 'idx_products_custom_category', columns: {#categoryId})
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get composition => text()(); // generic salt string
  IntColumn get categoryId => integer().nullable().references(ProductCategories, #id, onDelete: KeyAction.setNull)();
  TextColumn get hsnCode => text().nullable()(); // Indian GST HSN code
  TextColumn get rackLocation => text().nullable()(); // physical shelf reference
  IntColumn get minStockThreshold =>
      integer().withDefault(const Constant(10))(); // reorder point

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

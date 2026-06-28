import 'package:drift/drift.dart';
import 'product_categories_table.dart';

@DataClassName('Product')
@TableIndex(name: 'idx_products_custom_category', columns: {#categoryId})
@TableIndex(name: 'idx_products_hsn', columns: {#hsnCode})
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get hsnCode => text()(); // Mandatory Indian GST HSN code
  TextColumn get packagingUnit => text().withDefault(Constant("10's"))();
  TextColumn get productType => text().withDefault(Constant('Tablet'))(); // v7
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))(); // v9

  IntColumn get categoryId => integer().nullable().references(ProductCategories, #id, onDelete: KeyAction.setNull)();

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

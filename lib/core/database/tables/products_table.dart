import 'package:drift/drift.dart';

/// Category of a pharmaceutical product per Indian regulatory classification.
enum ProductCategory { otc, rx, scheduleH, scheduleH1, cosmetics }

@DataClassName('Product')
@TableIndex(name: 'idx_product_composition', columns: {#composition})
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get composition => text()(); // generic salt string
  TextColumn get hsnCode => text().nullable()(); // Indian GST HSN code
  TextColumn get category =>
      textEnum<ProductCategory>().withDefault(const Constant('otc'))();
  TextColumn get rackLocation => text().nullable()(); // physical shelf reference
  IntColumn get minStockThreshold =>
      integer().withDefault(const Constant(10))(); // reorder point

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

import 'package:drift/drift.dart';

/// Category of a pharmaceutical product per Indian regulatory classification.
enum ProductCategory { otc, rx, scheduleH, scheduleH1 }

@DataClassName('Product')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get composition => text().nullable()(); // generic salt string
  TextColumn get hsnCode => text().nullable()(); // Indian GST HSN code
  TextColumn get category =>
      textEnum<ProductCategory>().withDefault(const Constant('otc'))();
  TextColumn get rackLocation => text().nullable()(); // physical shelf reference
  RealColumn get minStockThreshold =>
      real().withDefault(const Constant(5.0))(); // reorder point

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

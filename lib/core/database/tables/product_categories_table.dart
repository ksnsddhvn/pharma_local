import 'package:drift/drift.dart';

@DataClassName('ProductCategory')
class ProductCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()(); // Simple English categories managed by owner (e.g., "Cough & Cold")
  TextColumn get description => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))();
}

import 'package:flutter/material.dart';
import '../../../core/database/tables/products_table.dart';
import '../../../core/theme/app_theme.dart';

class ProductCategoryBadge extends StatelessWidget {
  final ProductCategory category;
  const ProductCategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _info();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  (String, Color) _info() {
    switch (category) {
      case ProductCategory.otc:
        return ('OTC', AppColors.otcColor);
      case ProductCategory.rx:
        return ('Rx', AppColors.rxColor);
      case ProductCategory.scheduleH:
        return ('SCH-H', AppColors.scheduleHColor);
      case ProductCategory.scheduleH1:
        return ('SCH-H1', AppColors.scheduleH1Color);
    }
  }
}

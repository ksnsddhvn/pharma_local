import 'package:flutter/material.dart';

class ProductIconUtils {
  static IconData getIconForType(String productType) {
    switch (productType) {
      case 'Tablet':
        return Icons.medication;
      case 'Syrup':
        return Icons.water_drop;
      case 'Injection':
        return Icons.vaccines;
      case 'Cream / Ointment':
        return Icons.healing;
      case 'Diaper':
        return Icons.child_care;
      case 'Powder':
        return Icons.spa;
      case 'Toothpaste':
        return Icons.brush;
      default:
        return Icons.shopping_bag;
    }
  }
}

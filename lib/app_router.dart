import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_screen.dart';
import '../features/products/add_edit_product_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/inventory/receive_stock_screen.dart';
import '../features/sales/sales_screen.dart';
import '../features/sales/checkout_screen.dart';
import '../features/suppliers/suppliers_screen.dart';
import '../features/suppliers/supplier_detail_screen.dart';
import '../features/reports/reports_screen.dart';
import 'shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/products', builder: (_, __) => const ProductsScreen()),
        GoRoute(path: '/inventory', builder: (_, __) => const InventoryScreen()),
        GoRoute(path: '/sales', builder: (_, __) => const SalesScreen()),
        GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      ],
    ),
    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/products/add',
      builder: (_, __) => const AddEditProductScreen(),
    ),
    GoRoute(
      path: '/products/edit/:id',
      builder: (_, state) => AddEditProductScreen(
          productId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/inventory/receive',
      builder: (_, __) => const ReceiveStockScreen(),
    ),
    GoRoute(
      path: '/sales/checkout',
      builder: (_, __) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/suppliers/:id',
      builder: (_, state) => SupplierDetailScreen(
          supplierId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

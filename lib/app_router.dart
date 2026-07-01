import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_screen.dart';
import '../features/products/add_edit_product_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/inventory/receive_stock_screen.dart';
import '../features/inventory/product_detail_screen.dart';
import '../features/sales/sales_screen.dart';
import '../features/sales/new_sale_screen.dart';
import '../features/sales/checkout_screen.dart';
import '../features/suppliers/suppliers_screen.dart';
import '../features/suppliers/supplier_detail_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/secure_gateway_screen.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Allow access to the gateway
      if (state.matchedLocation.startsWith('/secure-gateway')) return null;

      final isUnlocked = ref.read(sessionUnlockedProvider);
      if (isUnlocked) return null;

      try {
        final settings = await ref.read(securitySettingsProvider.future);
        if (settings != null && settings.isAppLockEnabled) {
          return '/secure-gateway?redirect=${state.matchedLocation}';
        }
      } catch (e) {
        // Fallback to unlocked on error
      }
      
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => DashboardScreen()),
          GoRoute(path: '/products', builder: (_, __) => ProductsScreen()),
          GoRoute(path: '/inventory', builder: (_, __) => InventoryScreen()),
          GoRoute(path: '/sales', builder: (_, __) => SalesScreen()),
          GoRoute(path: '/suppliers', builder: (_, __) => SuppliersScreen()),
          GoRoute(path: '/reports', builder: (_, __) => ReportsScreen()),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/settings',
        builder: (_, __) => SettingsScreen(),
      ),
      GoRoute(
        path: '/secure-gateway',
        builder: (context, state) => SecureGatewayScreen(redirectPath: state.uri.queryParameters['redirect'] ?? '/'),
      ),
      GoRoute(
        path: '/products/add',
        builder: (_, __) => AddEditProductScreen(),
      ),
      GoRoute(
        path: '/products/edit/:id',
        builder: (_, state) => AddEditProductScreen(
            productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/inventory/receive',
        builder: (_, __) => ReceiveStockScreen(),
      ),
      GoRoute(
        path: '/inventory/product/:id',
        builder: (_, state) => ProductDetailScreen(
            productId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/sales/new',
        builder: (_, __) => NewSaleScreen(),
      ),
      GoRoute(
        path: '/sales/checkout',
        builder: (_, __) => CheckoutScreen(),
      ),
      GoRoute(
        path: '/suppliers/:id',
        builder: (_, state) => SupplierDetailScreen(
            supplierId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
});

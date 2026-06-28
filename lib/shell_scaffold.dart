import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  static const _tabs = [
    (path: '/', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    (path: '/products', icon: Icons.medication_outlined, activeIcon: Icons.medication, label: 'Products'),
    (path: '/inventory', icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Inventory'),
    (path: '/sales', icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale, label: 'Sales'),
    (path: '/suppliers', icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping, label: 'Suppliers'),
    (path: '/reports', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(_tabs[i].path),
          destinations: _tabs
              .map((t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: t.label,
                  ))
              .toList(),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}

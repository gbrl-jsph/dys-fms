import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

/// A bottom navigation destination tied to a [StatefulShellRoute] branch.
///
/// [branchIndex] is the branch order defined in `app_router.dart` (0-based).
class _NavItem {
  const _NavItem({
    required this.branchIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final int branchIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Application shell (blueprint §4.8, navigation-map Rule 4).
///
/// Hosts the active [StatefulShellRoute] branch and renders the role-specific
/// bottom navigation bar per the navigation-map matrix. The Users tab is
/// Business Owner only (Rule 9); Login and Sector Switcher are outside the
/// shell (Rule 4).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final List<_NavItem> items = _navItemsFor(
      isBusinessOwner: authProvider.state.user?.isBusinessOwner ?? false,
      isEventManager: authProvider.state.user?.isEventManager ?? false,
    );

    final int currentIndex = items.indexWhere(
      (item) => item.branchIndex == navigationShell.currentIndex,
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          items[index].branchIndex,
          initialLocation: index == currentIndex,
        ),
        destinations: [
          for (final _NavItem item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }

  /// Role-specific bottom nav items per the navigation-map matrix:
  /// BO: Dashboard, Sales, Expenses, Payroll, Users, Reports
  /// EM: Dashboard, Sales, Expenses, Payroll, Reports
  /// EE: Dashboard, Payroll, Reports
  List<_NavItem> _navItemsFor({
    required bool isBusinessOwner,
    required bool isEventManager,
  }) {
    final bool showOperational = isBusinessOwner || isEventManager;

    return [
      const _NavItem(
        branchIndex: 0,
        label: 'Dashboard',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      if (showOperational)
        const _NavItem(
          branchIndex: 1,
          label: 'Sales',
          icon: Icons.sell_outlined,
          selectedIcon: Icons.sell,
        ),
      if (showOperational)
        const _NavItem(
          branchIndex: 2,
          label: 'Expenses',
          icon: Icons.credit_card_outlined,
          selectedIcon: Icons.credit_card,
        ),
      const _NavItem(
        branchIndex: 3,
        label: 'Payroll',
        icon: Icons.group_outlined,
        selectedIcon: Icons.group,
      ),
      if (isBusinessOwner)
        const _NavItem(
          branchIndex: 4,
          label: 'Users',
          icon: Icons.group_add_outlined,
          selectedIcon: Icons.group_add,
        ),
      const _NavItem(
        branchIndex: 5,
        label: 'Reports',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
      ),
    ];
  }
}

import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expenses/presentation/screens/expenses_screen.dart';
import '../features/payroll/presentation/screens/payroll_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/sectors/presentation/screens/sector_switcher_screen.dart';
import '../features/sales/presentation/screens/sales_screen.dart';
import '../features/users/presentation/screens/users_screen.dart';

/// GoRouter configuration (blueprint §4.8).
///
/// Route guarding is driven by [AuthProvider]; `refreshListenable`
/// re-evaluates the redirect whenever auth state changes. Authenticated
/// screens live in the [StatefulShellRoute] wrapped by [AppShell], which
/// renders the role-specific bottom navigation bar (navigation-map
/// Rule 4). The Users screen is Business Owner only (Rule 9) and the
/// Sector Switcher is a pushed route outside the shell (Rule 8).
///
/// Branch order must match the nav items in [AppShell]:
/// 0 Dashboard, 1 Sales, 2 Expenses, 3 Payroll, 4 Users, 5 Reports.
class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.state.isAuthenticated;
        final bool isOnLogin = state.matchedLocation == '/login';
        final bool isBusinessOwner =
            authProvider.state.user?.isBusinessOwner ?? false;
        final bool isEventManager =
            authProvider.state.user?.isEventManager ?? false;

        if (!isAuthenticated) {
          return isOnLogin ? null : '/login';
        }
        if (isOnLogin) {
          return '/dashboard';
        }
        if (state.matchedLocation == '/users' && !isBusinessOwner) {
          return '/dashboard';
        }
        if (state.matchedLocation == '/sales' &&
            !isBusinessOwner &&
            !isEventManager) {
          return '/dashboard';
        }
        if (state.matchedLocation == '/expenses' &&
            !isBusinessOwner &&
            !isEventManager) {
          return '/dashboard';
        }
        // FR-007: Employees have no Reports access (API 403); the screen
        // is Business Owner / Event Manager only (navigation-map Rule 6).
        if (state.matchedLocation == '/reports' &&
            !isBusinessOwner &&
            !isEventManager) {
          return '/dashboard';
        }
        // FR-008: Only the Business Owner can switch sectors (API 403
        // for Event Managers and Employees).
        if (state.matchedLocation == '/sector-switcher' && !isBusinessOwner) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/sales',
                  builder: (context, state) => const SalesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/expenses',
                  builder: (context, state) => const ExpensesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/payroll',
                  builder: (context, state) => const PayrollScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/users',
                  builder: (context, state) => const UsersScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/reports',
                  builder: (context, state) => const ReportsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/sector-switcher',
          builder: (context, state) => const SectorSwitcherScreen(),
        ),
      ],
    );
  }
}

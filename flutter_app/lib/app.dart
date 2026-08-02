import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/payroll/presentation/providers/payroll_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/sales/presentation/providers/sales_provider.dart';
import 'features/sectors/presentation/providers/sectors_provider.dart';
import 'features/users/presentation/providers/users_provider.dart';
import 'providers/app_providers.dart';

/// Root application widget (blueprint §4.11).
///
/// Registers the global providers through [appProviders] and wires the
/// MaterialApp.router with the theme from [AppTheme] and the router
/// from [AppRouter].
class App extends StatelessWidget {
  const App({
    super.key,
    required this.authProvider,
    required this.usersProvider,
    required this.dashboardProvider,
    required this.salesProvider,
    required this.expensesProvider,
    required this.payrollProvider,
    required this.reportsProvider,
    required this.sectorsProvider,
    required this.router,
  });

  final AuthProvider authProvider;
  final UsersProvider usersProvider;
  final DashboardProvider dashboardProvider;
  final SalesProvider salesProvider;
  final ExpensesProvider expensesProvider;
  final PayrollProvider payrollProvider;
  final ReportsProvider reportsProvider;
  final SectorsProvider sectorsProvider;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders(
        authProvider: authProvider,
        usersProvider: usersProvider,
        dashboardProvider: dashboardProvider,
        salesProvider: salesProvider,
        expensesProvider: expensesProvider,
        payrollProvider: payrollProvider,
        reportsProvider: reportsProvider,
        sectorsProvider: sectorsProvider,
      ),
      child: MaterialApp.router(
        title: 'DYS FMS',
        theme: AppTheme.build(),
        routerConfig: router,
      ),
    );
  }
}

import 'package:provider/provider.dart';

import '../core/theme/theme_controller.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../features/expenses/presentation/providers/expenses_provider.dart';
import '../features/payroll/presentation/providers/payroll_provider.dart';
import '../features/reports/presentation/providers/reports_provider.dart';
import '../features/sales/presentation/providers/sales_provider.dart';
import '../features/sectors/presentation/providers/sectors_provider.dart';
import '../features/users/presentation/providers/users_provider.dart';

/// Global providers required by the application shell.
///
/// The shell derives its role-aware bottom navigation from
/// [AuthProvider], so it must be registered above the router. Feature
/// providers live in their own feature folders; this composition root
/// registers the app-level instances at startup.
///
/// `ChangeNotifierProvider<dynamic>` is the lowest common supertype of
/// the registered providers; MultiProvider accepts it covariantly.
List<ChangeNotifierProvider<dynamic>> appProviders({
  required ThemeController themeController,
  required AuthProvider authProvider,
  required UsersProvider usersProvider,
  required DashboardProvider dashboardProvider,
  required SalesProvider salesProvider,
  required ExpensesProvider expensesProvider,
  required PayrollProvider payrollProvider,
  required ReportsProvider reportsProvider,
  required SectorsProvider sectorsProvider,
}) {
  return [
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
    ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ChangeNotifierProvider<UsersProvider>.value(value: usersProvider),
    ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
    ChangeNotifierProvider<SalesProvider>.value(value: salesProvider),
    ChangeNotifierProvider<ExpensesProvider>.value(value: expensesProvider),
    ChangeNotifierProvider<PayrollProvider>.value(value: payrollProvider),
    ChangeNotifierProvider<ReportsProvider>.value(value: reportsProvider),
    ChangeNotifierProvider<SectorsProvider>.value(value: sectorsProvider),
  ];
}

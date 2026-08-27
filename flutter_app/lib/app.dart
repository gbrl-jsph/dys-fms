import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
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
/// from [AppRouter]. The whole tree rebuilds when [themeController]
/// changes so Light / Dark / System modes apply globally without any
/// per-screen theme duplication.
class App extends StatefulWidget {
  const App({
    super.key,
    required this.themeController,
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

  final ThemeController themeController;
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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Follow the OS brightness in `system` mode so widget color tokens
    // stay in sync with the theme MaterialApp resolves.
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        widget.themeController.handlePlatformBrightnessChanged;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = widget.themeController;

    return MultiProvider(
      providers: appProviders(
        themeController: themeController,
        authProvider: widget.authProvider,
        usersProvider: widget.usersProvider,
        dashboardProvider: widget.dashboardProvider,
        salesProvider: widget.salesProvider,
        expensesProvider: widget.expensesProvider,
        payrollProvider: widget.payrollProvider,
        reportsProvider: widget.reportsProvider,
        sectorsProvider: widget.sectorsProvider,
      ),
      child: ListenableBuilder(
        listenable: themeController,
        builder: (BuildContext context, Widget? child) {
          final Brightness resolved = themeController.resolve(
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
          );
          AppColors.setBrightness(resolved);

          return MaterialApp.router(
            title: 'DYS FMS',
            theme: AppTheme.build(Brightness.light),
            darkTheme: AppTheme.build(Brightness.dark),
            themeMode: themeController.mode,
            routerConfig: widget.router,
            // Flip the status-bar icons with the resolved brightness so
            // they stay readable over the scaffold surface in both modes.
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: resolved == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

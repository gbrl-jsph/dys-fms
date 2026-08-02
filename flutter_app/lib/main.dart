import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'data/api/api_client.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/storage/secure_storage.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/expenses/data/repositories/expenses_repository.dart';
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/payroll/data/repositories/payroll_repository.dart';
import 'features/payroll/presentation/providers/payroll_provider.dart';
import 'features/reports/data/repositories/reports_repository.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/sales/data/repositories/sales_repository.dart';
import 'features/sales/presentation/providers/sales_provider.dart';
import 'features/sectors/data/repositories/sectors_repository.dart';
import 'features/sectors/presentation/providers/sectors_provider.dart';
import 'features/users/data/repositories/users_repository.dart';
import 'features/users/presentation/providers/users_provider.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorage secureStorage = SecureStorage();

  // Wire secure storage as the token provider for the auth interceptor.
  ApiClient.init(tokenProvider: secureStorage.getToken);

  final AuthRepository authRepository = AuthRepository(
    ApiClient.instance,
    secureStorage,
  );
  final AuthProvider authProvider = AuthProvider(authRepository);

  final UsersRepository usersRepository = UsersRepository(ApiClient.instance);
  final UsersProvider usersProvider = UsersProvider(usersRepository);

  final DashboardRepository dashboardRepository = DashboardRepository(
    ApiClient.instance,
  );
  final DashboardProvider dashboardProvider = DashboardProvider(
    dashboardRepository,
  );

  final SalesRepository salesRepository = SalesRepository(ApiClient.instance);
  final SalesProvider salesProvider = SalesProvider(salesRepository);

  final ExpensesRepository expensesRepository = ExpensesRepository(
    ApiClient.instance,
  );
  final ExpensesProvider expensesProvider = ExpensesProvider(
    expensesRepository,
  );

  final PayrollRepository payrollRepository = PayrollRepository(
    ApiClient.instance,
  );
  final PayrollProvider payrollProvider = PayrollProvider(payrollRepository);

  final ReportsRepository reportsRepository = ReportsRepository(
    ApiClient.instance,
  );
  final ReportsProvider reportsProvider = ReportsProvider(reportsRepository);

  final SectorsRepository sectorsRepository = SectorsRepository(
    ApiClient.instance,
  );
  final SectorsProvider sectorsProvider = SectorsProvider(sectorsRepository);

  // Detect a stored token so the router redirects correctly on startup.
  await authProvider.checkAuthStatus();

  final GoRouter router = AppRouter.create(authProvider);

  runApp(
    App(
      authProvider: authProvider,
      usersProvider: usersProvider,
      dashboardProvider: dashboardProvider,
      salesProvider: salesProvider,
      expensesProvider: expensesProvider,
      payrollProvider: payrollProvider,
      reportsProvider: reportsProvider,
      sectorsProvider: sectorsProvider,
      router: router,
    ),
  );
}

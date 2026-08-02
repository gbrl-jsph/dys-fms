import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/core/theme/theme_controller.dart';
import 'package:dys_fms/core/theme/theme_mode_store.dart';
import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/auth/data/repositories/auth_repository.dart';
import 'package:dys_fms/features/auth/data/storage/secure_storage.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/expenses/data/repositories/expenses_repository.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:dys_fms/features/payroll/data/repositories/payroll_repository.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';
import 'package:dys_fms/features/reports/data/repositories/reports_repository.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';
import 'package:dys_fms/features/sales/data/repositories/sales_repository.dart';
import 'package:dys_fms/features/sales/presentation/providers/sales_provider.dart';
import 'package:dys_fms/features/sectors/data/repositories/sectors_repository.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';
import 'package:dys_fms/features/users/data/repositories/users_repository.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final SecureStorage secureStorage = SecureStorage();
    ApiClient.init(tokenProvider: secureStorage.getToken);
    final AuthProvider authProvider = AuthProvider(
      AuthRepository(ApiClient.instance, secureStorage),
    );
    final UsersProvider usersProvider = UsersProvider(
      UsersRepository(ApiClient.instance),
    );
    final DashboardProvider dashboardProvider = DashboardProvider(
      DashboardRepository(ApiClient.instance),
    );
    final SalesProvider salesProvider = SalesProvider(
      SalesRepository(ApiClient.instance),
    );
    final ExpensesProvider expensesProvider = ExpensesProvider(
      ExpensesRepository(ApiClient.instance),
    );
    final PayrollProvider payrollProvider = PayrollProvider(
      PayrollRepository(ApiClient.instance),
    );
    final ReportsProvider reportsProvider = ReportsProvider(
      ReportsRepository(ApiClient.instance),
    );
    final SectorsProvider sectorsProvider = SectorsProvider(
      SectorsRepository(ApiClient.instance),
    );
    final ThemeController themeController = ThemeController(ThemeModeStore());

    await tester.pumpWidget(
      App(
        authProvider: authProvider,
        usersProvider: usersProvider,
        dashboardProvider: dashboardProvider,
        salesProvider: salesProvider,
        expensesProvider: expensesProvider,
        payrollProvider: payrollProvider,
        reportsProvider: reportsProvider,
        sectorsProvider: sectorsProvider,
        themeController: themeController,
        router: AppRouter.create(authProvider),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('DYS Financial Management System (DYS FMS)'),
      findsOneWidget,
    );
    expect(find.text('Log In'), findsOneWidget);
  });
}

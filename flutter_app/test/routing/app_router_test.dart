import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/core/theme/theme_controller.dart';
import 'package:dys_fms/core/theme/theme_mode_store.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';
import 'package:dys_fms/features/sales/presentation/providers/sales_provider.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_dashboard_repository.dart';
import '../helpers/fake_expenses_repository.dart';
import '../helpers/fake_payroll_repository.dart';
import '../helpers/fake_reports_repository.dart';
import '../helpers/fake_sales_repository.dart';
import '../helpers/fake_sectors_repository.dart';
import '../helpers/fake_users_repository.dart';

const Map<String, dynamic> eventManagerUserJson = {
  'id': 2,
  'name': 'Maria Santos',
  'email': 'maria@dys.com',
  'role': 'Event Manager',
  'sector_id': 2,
  'account_status': 'Active',
};

const Map<String, dynamic> employeeUserJson = {
  'id': 3,
  'name': 'Ana Reyes',
  'email': 'ana@dys.com',
  'role': 'Employee/Staff',
  'sector_id': 1,
  'account_status': 'Active',
};

const FinancialSummary _sampleSummary = FinancialSummary(
  totalSales: 150000,
  totalExpenses: 85000,
  netBalance: 65000,
  payrollExpenses: 40000,
  sectorId: 1,
  sectorName: 'DYS Events',
);

void main() {
  late FakeAuthRepository fakeRepository;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeRepository = FakeAuthRepository();
  });

  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    bool authenticated = false,
    Map<String, dynamic>? storedUserJson,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final AuthProvider provider = AuthProvider(fakeRepository);
    if (authenticated) {
      fakeRepository.onIsAuthenticated = () async => true;
      fakeRepository.onGetStoredUser = () async =>
          UserModel.fromJson(storedUserJson ?? ownerUserJson);
      await provider.checkAuthStatus();
    }

    final UsersProvider usersProvider = UsersProvider(FakeUsersRepository());
    final FakeDashboardRepository dashboardRepository =
        FakeDashboardRepository();
    dashboardRepository.onGetSummary = (_) async => _sampleSummary;
    final DashboardProvider dashboardProvider = DashboardProvider(
      dashboardRepository,
    );
    final FakeSalesRepository salesRepository = FakeSalesRepository();
    salesRepository.onGetSales = (_) async => const [];
    final SalesProvider salesProvider = SalesProvider(salesRepository);
    final FakeExpensesRepository expensesRepository = FakeExpensesRepository();
    expensesRepository.onGetExpenses = (_) async => const [];
    final ExpensesProvider expensesProvider = ExpensesProvider(
      expensesRepository,
    );
    final FakePayrollRepository payrollRepository = FakePayrollRepository();
    payrollRepository.onGetPayroll = (_) async => const [];
    final PayrollProvider payrollProvider = PayrollProvider(payrollRepository);
    final ReportsProvider reportsProvider = ReportsProvider(
      FakeReportsRepository(),
    );
    final FakeSectorsRepository sectorsRepository = FakeSectorsRepository();
    sectorsRepository.onGetSectors = () async => const [];
    final SectorsProvider sectorsProvider = SectorsProvider(sectorsRepository);

    final GoRouter router = AppRouter.create(provider);

    await tester.pumpWidget(
      App(
        authProvider: provider,
        usersProvider: usersProvider,
        dashboardProvider: dashboardProvider,
        salesProvider: salesProvider,
        expensesProvider: expensesProvider,
        payrollProvider: payrollProvider,
        reportsProvider: reportsProvider,
        sectorsProvider: sectorsProvider,
        themeController: ThemeController(ThemeModeStore()),
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    return router;
  }

  testWidgets('unauthenticated user is shown the login screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'unauthenticated user visiting /dashboard is redirected to /login',
    (WidgetTester tester) async {
      final GoRouter router = await pumpApp(tester);

      router.go('/dashboard');
      await tester.pumpAndSettle();

      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('QUICK ACTIONS'), findsNothing);
    },
  );

  testWidgets('app launch with a stored session lands on the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, authenticated: true);

    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
    expect(find.text('Log In'), findsNothing);
  });

  testWidgets(
    'authenticated user visiting /login is redirected to /dashboard',
    (WidgetTester tester) async {
      final GoRouter router = await pumpApp(tester, authenticated: true);

      router.go('/login');
      await tester.pumpAndSettle();

      expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
      expect(find.text('Log In'), findsNothing);
    },
  );

  testWidgets('owner visiting /users is shown the manage users screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/users');
    await tester.pumpAndSettle();

    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('non-owner visiting /users is redirected to /dashboard', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/users');
    await tester.pumpAndSettle();

    expect(find.text('Manage Users'), findsNothing);
    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
  });

  testWidgets('owner visiting /sales is shown the record sale screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/sales');
    await tester.pumpAndSettle();

    expect(find.text('Record Sale'), findsOneWidget);
  });

  testWidgets('event manager visiting /sales is shown the record sale screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/sales');
    await tester.pumpAndSettle();

    expect(find.text('Record Sale'), findsOneWidget);
  });

  testWidgets('employee visiting /sales is redirected to /dashboard', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    router.go('/sales');
    await tester.pumpAndSettle();

    expect(find.text('Record Sale'), findsNothing);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
  });

  testWidgets('owner visiting /expenses is shown the record expense screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/expenses');
    await tester.pumpAndSettle();

    expect(find.text('Record Expense'), findsOneWidget);
  });

  testWidgets('event manager visiting /expenses is shown the record expense '
      'screen', (WidgetTester tester) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/expenses');
    await tester.pumpAndSettle();

    expect(find.text('Record Expense'), findsOneWidget);
  });

  testWidgets('employee visiting /expenses is redirected to /dashboard', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    router.go('/expenses');
    await tester.pumpAndSettle();

    expect(find.text('Record Expense'), findsNothing);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
  });

  testWidgets('owner bottom nav includes the Users tab', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, authenticated: true);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('tapping the Users tab opens the manage users screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, authenticated: true);

    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();

    expect(find.text('USER LIST'), findsOneWidget);
    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('event manager bottom nav hides the Users tab', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('employee bottom nav shows only Dashboard and Payroll', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Sales'), findsNothing);
    expect(find.text('Expenses'), findsNothing);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsNothing);
  });

  testWidgets('owner visiting /payroll is shown the payroll screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/payroll');
    await tester.pumpAndSettle();

    expect(find.text('Save Payroll Record'), findsOneWidget);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
  });

  testWidgets('event manager visiting /payroll is shown the payroll screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/payroll');
    await tester.pumpAndSettle();

    expect(find.text('Save Payroll Record'), findsNothing);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
  });

  testWidgets('employee visiting /payroll is shown the payroll screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    router.go('/payroll');
    await tester.pumpAndSettle();

    expect(find.text('Save Payroll Record'), findsNothing);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
  });

  testWidgets('owner visiting /reports is shown the financial reports screen', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/reports');
    await tester.pumpAndSettle();

    expect(find.text('Financial Reports'), findsOneWidget);
    expect(find.text('Generate Report'), findsOneWidget);
  });

  testWidgets('event manager visiting /reports is shown the financial '
      'reports screen', (WidgetTester tester) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/reports');
    await tester.pumpAndSettle();

    expect(find.text('Financial Reports'), findsOneWidget);
    expect(find.text('Generate Report'), findsOneWidget);
  });

  testWidgets('employee visiting /reports is redirected to /dashboard', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    router.go('/reports');
    await tester.pumpAndSettle();

    expect(find.text('Financial Reports'), findsNothing);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
  });

  testWidgets('owner dashboard Manage Users quick action navigates to /users', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, authenticated: true);

    expect(find.text('Manage Users'), findsOneWidget);

    await tester.tap(find.text('Manage Users'));
    await tester.pumpAndSettle();

    expect(find.text('USER LIST'), findsOneWidget);
  });

  testWidgets('non-owner dashboard hides the Manage Users quick action', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    expect(find.text('Manage Users'), findsNothing);
  });

  testWidgets('employee dashboard hides the Manage Users quick action', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    expect(find.text('Manage Users'), findsNothing);
  });

  testWidgets('owner visiting /sector-switcher is shown the sector switcher', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/sector-switcher');
    await tester.pumpAndSettle();

    expect(find.text('Switch Business Sector'), findsOneWidget);
    expect(find.text('BUSINESS SECTORS'), findsOneWidget);
  });

  testWidgets('event manager visiting /sector-switcher is redirected to '
      '/dashboard', (WidgetTester tester) async {
    final GoRouter router = await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    router.go('/sector-switcher');
    await tester.pumpAndSettle();

    expect(find.text('Switch Business Sector'), findsNothing);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
  });

  testWidgets(
    'employee visiting /sector-switcher is redirected to /dashboard',
    (WidgetTester tester) async {
      final GoRouter router = await pumpApp(
        tester,
        authenticated: true,
        storedUserJson: employeeUserJson,
      );

      router.go('/sector-switcher');
      await tester.pumpAndSettle();

      expect(find.text('Switch Business Sector'), findsNothing);
      expect(find.text('QUICK ACTIONS'), findsOneWidget);
    },
  );
}

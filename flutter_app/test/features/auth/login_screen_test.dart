import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/auth/presentation/screens/login_screen.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';
import 'package:dys_fms/features/sales/presentation/providers/sales_provider.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_dashboard_repository.dart';
import '../../helpers/fake_expenses_repository.dart';
import '../../helpers/fake_payroll_repository.dart';
import '../../helpers/fake_reports_repository.dart';
import '../../helpers/fake_sales_repository.dart';
import '../../helpers/fake_sectors_repository.dart';
import '../../helpers/fake_users_repository.dart';

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
  late AuthProvider provider;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeRepository = FakeAuthRepository();
    provider = AuthProvider(fakeRepository);
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('renders email field, password field, and Log In button', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('empty email shows "Email is required."', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
  });

  testWidgets('empty password shows "Password is required."', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsNothing);
  });

  testWidgets('invalid email format shows "Enter a valid email address."', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'not-an-email');
    await tester.enterText(find.byType(TextField).last, 'SecurePass123');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Password is required.'), findsNothing);
  });

  testWidgets('password field toggles visibility with the eye icon', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    TextField passwordField() =>
        tester.widget<TextField>(find.byType(TextField).last);

    expect(passwordField().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(passwordField().obscureText, isTrue);
  });

  testWidgets('Log In button shows loading state on tap', (
    WidgetTester tester,
  ) async {
    final Completer<LoginResponse> completer = Completer<LoginResponse>();
    fakeRepository.onLogin = (_, _) => completer.future;

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'SecurePass123');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    completer.complete(buildLoginResponse());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('API error displays the error message container', (
    WidgetTester tester,
  ) async {
    fakeRepository.onLogin = (_, _) => throw buildUnauthorizedException();

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'wrong');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('successful login navigates to the dashboard', (
    WidgetTester tester,
  ) async {
    fakeRepository.onLogin = (_, _) async => buildLoginResponse();

    final GoRouter router = AppRouter.create(provider);
    final UsersProvider usersProvider = UsersProvider(FakeUsersRepository());
    final FakeDashboardRepository dashboardRepository =
        FakeDashboardRepository();
    dashboardRepository.onGetSummary = (_) async => _sampleSummary;
    final DashboardProvider dashboardProvider = DashboardProvider(
      dashboardRepository,
    );
    final SalesProvider salesProvider = SalesProvider(FakeSalesRepository());
    final ExpensesProvider expensesProvider = ExpensesProvider(
      FakeExpensesRepository(),
    );
    final PayrollProvider payrollProvider = PayrollProvider(
      FakePayrollRepository(),
    );
    final ReportsProvider reportsProvider = ReportsProvider(
      FakeReportsRepository(),
    );
    final SectorsProvider sectorsProvider = SectorsProvider(
      FakeSectorsRepository(),
    );

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
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'SecurePass123');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
    expect(find.text('₱150,000.00'), findsOneWidget);
  });
}

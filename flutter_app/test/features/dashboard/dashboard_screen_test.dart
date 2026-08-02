import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/core/widgets/app_avatar.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_dashboard_repository.dart';

const FinancialSummary _sampleSummary = FinancialSummary(
  totalSales: 150000,
  totalExpenses: 85000,
  netBalance: 65000,
  payrollExpenses: 40000,
  sectorId: 1,
  sectorName: 'DYS Events',
);

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeDashboardRepository fakeDashboardRepository;
  late DashboardProvider dashboardProvider;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    authProvider = AuthProvider(fakeAuthRepository);

    fakeDashboardRepository = FakeDashboardRepository();
    fakeDashboardRepository.onGetSummary = (_) async => _sampleSummary;
    dashboardProvider = DashboardProvider(fakeDashboardRepository);
  });

  Future<void> pumpDashboard(
    WidgetTester tester, {
    Map<String, dynamic>? userJson,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(userJson ?? ownerUserJson);
    await authProvider.checkAuthStatus();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('owner dashboard renders summary cards and quick actions', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('DYS Events'), findsOneWidget);
    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
    expect(find.text('Total Sales'), findsOneWidget);
    expect(find.text('Total Exp.'), findsOneWidget);
    expect(find.text('Net Balance'), findsOneWidget);
    expect(find.text('₱150,000.00'), findsOneWidget);
    expect(find.text('₱85,000.00'), findsOneWidget);
    expect(find.text('₱65,000.00'), findsOneWidget);
    expect(find.text('SALES OVERVIEW'), findsOneWidget);
    expect(find.text('Graph placeholder'), findsOneWidget);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
    expect(find.text('Record Sale'), findsOneWidget);
    expect(find.text('Record Expense'), findsOneWidget);
    expect(find.text('View Reports'), findsOneWidget);
    expect(find.text('View Payroll'), findsOneWidget);
    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('owner sector chip navigates to the sector switcher', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/sector-switcher',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Switch Business Sector')),
          ),
        ),
      ],
    );

    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    await authProvider.checkAuthStatus();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.build(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('DYS Events'));
    await tester.pumpAndSettle();

    expect(find.text('Switch Business Sector'), findsOneWidget);
  });

  testWidgets('event manager dashboard hides Manage Users and the chart', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(
      tester,
      userJson: {
        'id': 2,
        'name': 'Maria Santos',
        'email': 'maria@dys.com',
        'role': 'Event Manager',
        'sector_id': 2,
        'account_status': 'Active',
      },
    );

    expect(find.text('B&DYS'), findsOneWidget);
    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
    expect(find.text('Record Sale'), findsOneWidget);
    expect(find.text('Record Expense'), findsOneWidget);
    expect(find.text('View Reports'), findsOneWidget);
    expect(find.text('View Payroll'), findsOneWidget);
    expect(find.text('Manage Users'), findsNothing);
    expect(find.text('SALES OVERVIEW'), findsNothing);
  });

  testWidgets('employee dashboard shows only the View Payroll quick action', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(
      tester,
      userJson: {
        'id': 3,
        'name': 'Ana Reyes',
        'email': 'ana@dys.com',
        'role': 'Employee/Staff',
        'sector_id': 1,
        'account_status': 'Active',
      },
    );

    expect(find.text('DYS Events'), findsOneWidget);
    expect(find.text('FINANCIAL SUMMARY'), findsNothing);
    expect(find.text('SALES OVERVIEW'), findsNothing);
    expect(find.text('View Payroll'), findsOneWidget);
    expect(find.text('Record Sale'), findsNothing);
    expect(find.text('Record Expense'), findsNothing);
    expect(find.text('View Reports'), findsNothing);
    expect(find.text('Manage Users'), findsNothing);
  });

  testWidgets('shows the loading indicator while the summary loads', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final Completer<FinancialSummary> completer = Completer<FinancialSummary>();
    fakeDashboardRepository.onGetSummary = (_) => completer.future;

    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    await authProvider.checkAuthStatus();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_sampleSummary);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('₱150,000.00'), findsOneWidget);
  });

  testWidgets('shows the error state and retries the summary load', (
    WidgetTester tester,
  ) async {
    fakeDashboardRepository.onGetSummary = (_) async =>
        throw Exception('Forbidden.');

    await pumpDashboard(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );

    fakeDashboardRepository.onGetSummary = (_) async => _sampleSummary;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Please try again.'), findsNothing);
    expect(find.text('₱150,000.00'), findsOneWidget);
  });

  testWidgets('the avatar menu shows the signed-in user and a Logout action', (
    WidgetTester tester,
  ) async {
    fakeAuthRepository.onLogout = () async {};
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    await authProvider.checkAuthStatus();

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Business Owner'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Logout ends the session and returns to the login screen', (
    WidgetTester tester,
  ) async {
    fakeAuthRepository.onLogout = () async {};
    final GoRouter router = GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (!authProvider.state.isAuthenticated) {
          return state.matchedLocation == '/login' ? null : '/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Login Stub'))),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );

    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    await authProvider.checkAuthStatus();

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.build(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppAvatar));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(authProvider.state.isAuthenticated, isFalse);
    expect(find.text('Login Stub'), findsOneWidget);
  });
}

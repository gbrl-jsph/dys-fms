import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/sectors/data/models/business_sector.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';
import 'package:dys_fms/features/sectors/presentation/screens/sector_switcher_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_dashboard_repository.dart';
import '../../helpers/fake_sectors_repository.dart';

DioException buildUnauthenticatedException() {
  final RequestOptions options = RequestOptions(path: '/api/business-sectors');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'Unauthenticated.'},
    ),
  );
}

DioException buildForbiddenException() {
  final RequestOptions options = RequestOptions(
    path: '/api/business-sectors/switch',
  );
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: 403,
      data: {'message': 'Forbidden.'},
    ),
  );
}

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
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeSectorsRepository fakeSectorsRepository;
  late SectorsProvider sectorsProvider;
  late FakeDashboardRepository fakeDashboardRepository;
  late DashboardProvider dashboardProvider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    authProvider = AuthProvider(fakeAuthRepository);
    await authProvider.checkAuthStatus();

    fakeSectorsRepository = FakeSectorsRepository();
    fakeSectorsRepository.onGetSectors = () async => buildSectorsList();
    fakeSectorsRepository.onSwitchSector = (sectorId) async =>
        buildSwitchResult();
    sectorsProvider = SectorsProvider(fakeSectorsRepository);

    fakeDashboardRepository = FakeDashboardRepository();
    fakeDashboardRepository.onGetSummary = (_) async => _sampleSummary;
    dashboardProvider = DashboardProvider(fakeDashboardRepository);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Map<String, dynamic>? userJson,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(userJson ?? ownerUserJson);
    await authProvider.checkAuthStatus();

    final GoRouter router = GoRouter(
      initialLocation: '/sector-switcher',
      routes: [
        GoRoute(
          path: '/sector-switcher',
          builder: (context, state) => const SectorSwitcherScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Dashboard Stub'))),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<SectorsProvider>.value(value: sectorsProvider),
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
    if (settle) {
      await tester.pumpAndSettle();
    }
  }

  testWidgets('the Owner sees the four sector cards with descriptions, the '
      'active badge, and the Switch/Cancel actions', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Switch Business Sector'), findsOneWidget);
    expect(
      find.text('Select the business sector you want to switch to.'),
      findsOneWidget,
    );
    expect(find.text('BUSINESS SECTORS'), findsOneWidget);
    expect(find.text('DYS Events'), findsWidgets);
    expect(find.text('B&DYS'), findsOneWidget);
    expect(find.text('Flavors by DYS'), findsOneWidget);
    expect(find.text('SnapDYS Memories'), findsOneWidget);
    expect(
      find.text('Event coordination and styling main branch'),
      findsOneWidget,
    );
    expect(find.text('Souvenirs'), findsOneWidget);
    expect(find.text('Grazing tables and celebration drinks'), findsOneWidget);
    expect(find.text('Video guestbook'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Currently active: DYS Events'), findsOneWidget);
    expect(find.text('Switch Sector'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('the Switch Sector button stays disabled until a different '
      'sector is selected', (WidgetTester tester) async {
    await pumpScreen(tester);

    ElevatedButton switchButton() => tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Switch Sector'),
    );

    expect(switchButton().onPressed, isNull);

    await tester.tap(find.text('DYS Events').first);
    await tester.pump();

    expect(switchButton().onPressed, isNull);

    await tester.tap(find.text('B&DYS'));
    await tester.pump();

    expect(switchButton().onPressed, isNotNull);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
  });

  testWidgets('switching sectors updates the client-side context, refreshes '
      'the Dashboard, and returns to it', (WidgetTester tester) async {
    int? switchTarget;
    int? refreshedSector;
    fakeSectorsRepository.onSwitchSector = (sectorId) async {
      switchTarget = sectorId;
      return buildSwitchResult();
    };
    fakeDashboardRepository.onGetSummary = (sectorId) async {
      refreshedSector = sectorId;
      return _sampleSummary;
    };

    await pumpScreen(tester);

    await tester.tap(find.text('B&DYS'));
    await tester.pump();
    await tester.tap(find.text('Switch Sector'));
    await tester.pumpAndSettle();

    expect(switchTarget, 2);
    expect(refreshedSector, 2);
    expect(authProvider.state.defaultSector?.id, 2);
    expect(authProvider.state.defaultSector?.name, 'B&DYS');
    expect(find.text('Dashboard Stub'), findsOneWidget);
  });

  testWidgets('a failed switch shows the error and keeps the current sector', (
    WidgetTester tester,
  ) async {
    fakeSectorsRepository.onSwitchSector = (_) async =>
        throw buildForbiddenException();

    await pumpScreen(tester);

    await tester.tap(find.text('B&DYS'));
    await tester.pump();
    await tester.tap(find.text('Switch Sector'));
    await tester.pumpAndSettle();

    expect(find.text('Forbidden.'), findsOneWidget);
    expect(find.text('Switch Business Sector'), findsOneWidget);
    expect(authProvider.state.defaultSector, isNull);
  });

  testWidgets('the back button returns to the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Stub'), findsOneWidget);
  });

  testWidgets('the Event Manager sees a read-only list with the assigned '
      'sector highlighted', (WidgetTester tester) async {
    await pumpScreen(tester, userJson: eventManagerUserJson);

    expect(find.text('B&DYS'), findsWidgets);
    expect(find.text('Currently active: B&DYS'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Switch Sector'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('the Employee sees a read-only list with the assigned sector '
      'highlighted', (WidgetTester tester) async {
    await pumpScreen(tester, userJson: employeeUserJson);

    expect(find.text('DYS Events'), findsWidgets);
    expect(find.text('Currently active: DYS Events'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Switch Sector'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('shows a loading indicator while the sectors load', (
    WidgetTester tester,
  ) async {
    final Completer<List<BusinessSector>> completer =
        Completer<List<BusinessSector>>();
    fakeSectorsRepository.onGetSectors = () => completer.future;

    await pumpScreen(tester, settle: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(buildSectorsList());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('B&DYS'), findsOneWidget);
  });

  testWidgets('shows the error state with a retry action', (
    WidgetTester tester,
  ) async {
    fakeSectorsRepository.onGetSectors = () async =>
        throw buildUnauthenticatedException();

    await pumpScreen(tester);

    expect(find.text('Unauthenticated.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    fakeSectorsRepository.onGetSectors = () async => buildSectorsList();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Unauthenticated.'), findsNothing);
    expect(find.text('B&DYS'), findsOneWidget);
  });

  testWidgets('shows the empty state when no sectors are returned', (
    WidgetTester tester,
  ) async {
    fakeSectorsRepository.onGetSectors = () async => [];

    await pumpScreen(tester);

    expect(find.text('No sectors available'), findsOneWidget);
    expect(find.text('DYS Events'), findsNothing);
  });
}

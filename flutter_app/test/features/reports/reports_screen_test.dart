import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/reports/data/models/report_data.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';
import 'package:dys_fms/features/reports/presentation/screens/reports_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_reports_repository.dart';

const Map<String, dynamic> eventManagerUserJson = {
  'id': 2,
  'name': 'Maria Santos',
  'email': 'maria@dys.com',
  'role': 'Event Manager',
  'sector_id': 2,
  'account_status': 'Active',
};

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeReportsRepository fakeReportsRepository;
  late ReportsProvider reportsProvider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    authProvider = AuthProvider(fakeAuthRepository);
    await authProvider.checkAuthStatus();

    fakeReportsRepository = FakeReportsRepository();
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async =>
            buildSummaryReport();
    reportsProvider = ReportsProvider(fakeReportsRepository);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ReportsProvider>.value(value: reportsProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const ReportsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the Owner sees the form and the empty state before generating', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Financial Reports'), findsOneWidget);
    expect(find.text('Report Type'), findsOneWidget);
    expect(find.text('Business Sector'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Generate Report'), findsOneWidget);
    expect(find.text('No report yet'), findsOneWidget);
    expect(find.text('Sales graph placeholder'), findsNothing);
  });

  testWidgets('generating a summary report shows the placeholders and the '
      'financial summary', (WidgetTester tester) async {
    String? sentType;
    int? sentSector;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentType = type;
          sentSector = sectorId;
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentType, 'summary');
    expect(sentSector, 1);
    expect(find.text('Sales graph placeholder'), findsOneWidget);
    expect(find.text('Expense chart placeholder'), findsOneWidget);
    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
    expect(find.text('₱150,000.00'), findsOneWidget);
    expect(find.text('₱85,000.00'), findsOneWidget);
    expect(find.text('₱65,000.00'), findsOneWidget);
    expect(find.text('₱40,000.00'), findsOneWidget);
    expect(find.text('No report yet'), findsNothing);
  });

  testWidgets('a sector switch discards the generated report and syncs the '
      'sector selector', (WidgetTester tester) async {
    int? sentSector;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentSector = sectorId;
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();
    expect(sentSector, 1);
    expect(find.text('No report yet'), findsNothing);

    authProvider.updateSector(const DefaultSector(id: 2, name: 'B&DYS'));
    await tester.pumpAndSettle();

    expect(find.text('No report yet'), findsOneWidget);
    expect(find.text('B&DYS'), findsOneWidget);

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();
    expect(sentSector, 2);
  });

  testWidgets('picked From/To dates are sent as date_from and date_to', (
    WidgetTester tester,
  ) async {
    String? sentFrom;
    String? sentTo;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentFrom = dateFrom == null ? null : _dateOnly(dateFrom);
          sentTo = dateTo == null ? null : _dateOnly(dateTo);
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.byType(TextField).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('28'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentFrom, endsWith('-15'));
    expect(sentTo, endsWith('-28'));
  });

  testWidgets('the Owner can generate a sales report', (
    WidgetTester tester,
  ) async {
    String? sentType;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentType = type;
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentType, 'sales');
    expect(find.text('Sales graph placeholder'), findsOneWidget);
  });

  testWidgets('the Owner can generate an expenses report', (
    WidgetTester tester,
  ) async {
    String? sentType;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentType = type;
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentType, 'expenses');
    expect(find.text('Expense chart placeholder'), findsOneWidget);
  });

  testWidgets('the Owner can generate an analytics report with the analytics '
      'placeholders', (WidgetTester tester) async {
    String? sentType;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentType = type;
          return buildAnalyticsReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentType, 'analytics');
    expect(find.text('Sales trend placeholder'), findsOneWidget);
    expect(find.text('Expense breakdown placeholder'), findsOneWidget);
    expect(find.text('Sector comparison placeholder'), findsOneWidget);
    expect(find.text('Sales graph placeholder'), findsNothing);
    expect(find.text('₱225,000.00'), findsOneWidget);
  });

  testWidgets('the Event Manager has no Analytics option, no sector selector, '
      'and no sector_id is sent', (WidgetTester tester) async {
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(eventManagerUserJson);
    await authProvider.checkAuthStatus();

    int? sentSector;
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentSector = sectorId;
          return buildSummaryReport();
        };

    await pumpScreen(tester);

    expect(find.text('Business Sector'), findsNothing);
    expect(find.byType(DropdownButtonFormField<int?>), findsNothing);
    expect(
      find.text('Reports are scoped to your assigned sector.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsNothing);
    expect(find.text('Sales'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    await tester.tap(find.text('Summary').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(sentSector, isNull);
    expect(find.text('₱150,000.00'), findsOneWidget);
  });

  testWidgets('shows the loading indicator while the report generates', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final Completer<ReportData> completer = Completer<ReportData>();
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) => completer.future;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ReportsProvider>.value(value: reportsProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const ReportsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate Report'));
    await tester.pump();
    await tester.pump();

    // Content spinner + the LoadingButton spinner.
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

    completer.complete(buildSummaryReport());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('₱150,000.00'), findsOneWidget);
  });

  testWidgets('backend error is shown with a retry action', (
    WidgetTester tester,
  ) async {
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          throw Exception('Forbidden.');
        };

    await pumpScreen(tester);

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async =>
            buildSummaryReport();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('₱150,000.00'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('the Owner can switch between cross-sector and per-sector '
      'reports', (WidgetTester tester) async {
    final List<int?> sentSectors = <int?>[];
    fakeReportsRepository.onGetReport =
        ({required type, dateFrom, dateTo, sectorId}) async {
          sentSectors.add(sectorId);
          return buildCrossSectorReport();
        };

    await pumpScreen(tester);

    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();
    expect(sentSectors, [1]);

    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();
    expect(sentSectors, [1, 2]);

    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Sectors').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate Report'));
    await tester.pumpAndSettle();
    expect(sentSectors, [1, 2, null]);
  });
}

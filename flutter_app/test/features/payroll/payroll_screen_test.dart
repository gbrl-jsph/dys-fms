import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/payroll/data/models/payroll_record.dart';
import 'package:dys_fms/features/payroll/data/models/save_payroll_request.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';
import 'package:dys_fms/features/payroll/presentation/screens/payroll_screen.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_payroll_repository.dart';
import '../../helpers/fake_users_repository.dart';

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
  'name': 'Pedro Reyes',
  'email': 'pedro@dys.com',
  'role': 'Employee/Staff',
  'sector_id': 1,
  'account_status': 'Active',
};

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeUsersRepository fakeUsersRepository;
  late UsersProvider usersProvider;
  late FakePayrollRepository fakePayrollRepository;
  late PayrollProvider payrollProvider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    authProvider = AuthProvider(fakeAuthRepository);
    await authProvider.checkAuthStatus();

    fakeUsersRepository = FakeUsersRepository();
    fakeUsersRepository.onGetUsers = () async => buildUsersList();
    usersProvider = UsersProvider(fakeUsersRepository);

    fakePayrollRepository = FakePayrollRepository();
    fakePayrollRepository.onGetPayroll = (_) async => buildPayrollList();
    payrollProvider = PayrollProvider(fakePayrollRepository);
  });

  Future<void> pumpScreen(WidgetTester tester, {bool withUsers = true}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          if (withUsers)
            ChangeNotifierProvider<UsersProvider>.value(value: usersProvider),
          ChangeNotifierProvider<PayrollProvider>.value(value: payrollProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const PayrollScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the Owner sees the calculation form and the payroll history '
      'list', (WidgetTester tester) async {
    await pumpScreen(tester);

    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Business Sector'), findsOneWidget);
    expect(find.text('Employee'), findsOneWidget);
    expect(find.text('Hours Worked'), findsOneWidget);
    expect(find.text('Hourly Rate (₱)'), findsOneWidget);
    expect(find.text('Pay Period'), findsOneWidget);
    expect(find.text('Save Payroll Record'), findsOneWidget);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
    expect(find.text('₱20,000.00'), findsOneWidget);
    expect(find.text('₱12,000.00'), findsOneWidget);
    expect(find.text('Ana Gomez'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('Pay period: Jul 15, 2026'), findsNWidgets(2));
    expect(find.text('160 h × ₱125.00'), findsOneWidget);
    expect(find.text('80 h × ₱150.00'), findsOneWidget);
    expect(find.text('DYS Events'), findsNWidgets(2));
    expect(find.text('B&DYS'), findsOneWidget);
    expect(find.text('Jul 28, 2026'), findsNWidgets(2));
  });

  testWidgets('shows the empty state when no payroll records exist', (
    WidgetTester tester,
  ) async {
    fakePayrollRepository.onGetPayroll = (_) async => [];

    await pumpScreen(tester);

    expect(find.text('No payroll records yet'), findsOneWidget);
  });

  testWidgets('shows the loading indicator while the payroll list loads', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final Completer<List<PayrollRecord>> completer =
        Completer<List<PayrollRecord>>();
    fakePayrollRepository.onGetPayroll = (_) => completer.future;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UsersProvider>.value(value: usersProvider),
          ChangeNotifierProvider<PayrollProvider>.value(value: payrollProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const PayrollScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No payroll records yet'), findsNothing);

    completer.complete(buildPayrollList());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('₱20,000.00'), findsOneWidget);
  });

  testWidgets('backend error is shown with a retry action', (
    WidgetTester tester,
  ) async {
    fakePayrollRepository.onGetPayroll = (_) async {
      throw Exception('Forbidden.');
    };

    await pumpScreen(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('saving an empty form shows all validation errors', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Save Payroll Record'));
    await tester.pumpAndSettle();

    expect(find.text('Employee is required.'), findsOneWidget);
    expect(find.text('Hours worked is required.'), findsOneWidget);
    expect(find.text('Hourly rate is required.'), findsOneWidget);
    expect(find.text('Pay period is required.'), findsOneWidget);
  });

  testWidgets('non-positive hours and rate show the positive-number errors', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.tap(find.text('Save Payroll Record'));
    await tester.pumpAndSettle();

    expect(
      find.text('Hours worked must be a positive number.'),
      findsOneWidget,
    );
    expect(find.text('Hourly rate must be a positive number.'), findsOneWidget);
  });

  testWidgets('values above the 99999999.99 ceiling show the limit errors', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '100000000');
    await tester.enterText(find.byType(TextField).at(1), '100000000');
    await tester.tap(find.text('Save Payroll Record'));
    await tester.pumpAndSettle();

    expect(
      find.text('Hours worked must not exceed 99999999.99.'),
      findsOneWidget,
    );
    expect(
      find.text('Hourly rate must not exceed 99999999.99.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'an overflowing computed salary shows the computed-salary error',
    (WidgetTester tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maria Santos').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '99999999.99');
      await tester.enterText(find.byType(TextField).at(1), '2');
      await tester.tap(find.text('Save Payroll Record'));
      await tester.pumpAndSettle();

      expect(
        find.text('Computed salary must not exceed 99999999.99.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('calculating payroll submits the request, picks the pay period, '
      'and clears the form', (WidgetTester tester) async {
    SavePayrollRequest? sentRequest;
    fakePayrollRepository.onCalculatePayroll = (request) async {
      sentRequest = request;
      return PayrollRecord.fromJson(secondPayrollJson);
    };

    await pumpScreen(tester);

    await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maria Santos').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '160');
    await tester.enterText(find.byType(TextField).at(1), '125');

    await tester.tap(find.byType(TextField).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Payroll Record'));
    await tester.pumpAndSettle();

    expect(sentRequest?.userId, 2);
    expect(sentRequest?.hoursWorked, 160);
    expect(sentRequest?.hourlyRate, 125);
    expect(sentRequest?.payPeriod.day, 15);
    expect(
      find.text(
        'Payroll calculated and saved successfully. Expense record '
        'auto-created.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('the Owner can change the sector and the list reloads', (
    WidgetTester tester,
  ) async {
    final List<int?> requestedSectors = <int?>[];
    fakePayrollRepository.onGetPayroll = (sectorId) async {
      requestedSectors.add(sectorId);
      return buildPayrollList();
    };

    await pumpScreen(tester);
    expect(requestedSectors, [1]);

    await tester.tap(find.byType(DropdownButtonFormField<int>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();

    expect(requestedSectors, [1, 2]);
  });

  testWidgets('the Event Manager sees only the records list — no calculate '
      'controls', (WidgetTester tester) async {
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(eventManagerUserJson);
    await authProvider.checkAuthStatus();

    final List<int?> requestedSectors = <int?>[];
    fakePayrollRepository.onGetPayroll = (sectorId) async {
      requestedSectors.add(sectorId);
      return buildPayrollList();
    };

    await pumpScreen(tester, withUsers: false);

    expect(requestedSectors, [null]);
    expect(find.text('Save Payroll Record'), findsNothing);
    expect(find.text('Hours Worked'), findsNothing);
    expect(find.text('Business Sector'), findsNothing);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
    expect(find.text('₱20,000.00'), findsOneWidget);
    expect(
      find.text(
        'You can only view your own payroll records. Payroll is '
        'calculated by the Business Owner.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the Employee sees only their own records — no calculate '
      'controls', (WidgetTester tester) async {
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(employeeUserJson);
    await authProvider.checkAuthStatus();

    await pumpScreen(tester, withUsers: false);

    expect(find.text('Save Payroll Record'), findsNothing);
    expect(find.text('Employee'), findsNothing);
    expect(find.text('PAYROLL HISTORY'), findsOneWidget);
    expect(find.text('Ana Gomez'), findsOneWidget);
    expect(
      find.text(
        'You can only view your own payroll records. Payroll is '
        'calculated by the Business Owner.',
      ),
      findsOneWidget,
    );
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/expenses/data/models/expense_record.dart';
import 'package:dys_fms/features/expenses/data/models/save_expense_request.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:dys_fms/features/expenses/presentation/screens/expenses_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_expenses_repository.dart';

const Map<String, dynamic> eventManagerUserJson = {
  'id': 2,
  'name': 'Maria Santos',
  'email': 'maria@dys.com',
  'role': 'Event Manager',
  'sector_id': 2,
  'account_status': 'Active',
};

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeExpensesRepository fakeExpensesRepository;
  late ExpensesProvider expensesProvider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    authProvider = AuthProvider(fakeAuthRepository);
    await authProvider.checkAuthStatus();

    fakeExpensesRepository = FakeExpensesRepository();
    fakeExpensesRepository.onGetExpenses = (_) async => buildExpensesList();
    expensesProvider = ExpensesProvider(fakeExpensesRepository);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ExpensesProvider>.value(
            value: expensesProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          home: const ExpensesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the app bar, form fields, and the expense list', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Record Expense'), findsOneWidget);
    expect(find.text('Business Sector'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
    expect(find.text('EXPENSE LIST'), findsOneWidget);
    expect(find.text('₱5,000.00'), findsOneWidget);
    expect(find.text('Catering supplies'), findsOneWidget);
    expect(find.text('₱20,000.00'), findsOneWidget);
    expect(find.text('DYS Events'), findsNWidgets(3));
    expect(find.text('Juan Dela Cruz'), findsNWidgets(2));
    expect(find.text('Jul 28, 2026'), findsNWidgets(2));
  });

  testWidgets('shows the empty state when no expenses exist', (
    WidgetTester tester,
  ) async {
    fakeExpensesRepository.onGetExpenses = (_) async => [];

    await pumpScreen(tester);

    expect(find.text('No records yet'), findsOneWidget);
  });

  testWidgets('shows the loading indicator while the expense list loads', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final Completer<List<ExpenseRecord>> completer =
        Completer<List<ExpenseRecord>>();
    fakeExpensesRepository.onGetExpenses = (_) => completer.future;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ExpensesProvider>.value(
            value: expensesProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          home: const ExpensesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No records yet'), findsNothing);

    completer.complete(buildExpensesList());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('₱5,000.00'), findsOneWidget);
  });

  testWidgets('backend error is shown with a retry action', (
    WidgetTester tester,
  ) async {
    fakeExpensesRepository.onGetExpenses = (_) async {
      throw Exception('Forbidden.');
    };

    await pumpScreen(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('saving an empty form shows the amount validation error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Amount is required.'), findsOneWidget);
    expect(find.text('Sector is required.'), findsNothing);
  });

  testWidgets('a non-positive amount shows the positive-number error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Amount must be a positive number.'), findsOneWidget);
  });

  testWidgets('an amount over the database limit shows the ceiling error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '1000000');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Amount must not exceed 999999.99.'), findsOneWidget);
  });

  testWidgets('a sector switch reloads the list and syncs the selector', (
    WidgetTester tester,
  ) async {
    final List<int?> requestedSectors = <int?>[];
    fakeExpensesRepository.onGetExpenses = (sectorId) async {
      requestedSectors.add(sectorId);
      return buildExpensesList();
    };

    await pumpScreen(tester);
    expect(requestedSectors, [1]);

    authProvider.updateSector(const DefaultSector(id: 2, name: 'B&DYS'));
    await tester.pumpAndSettle();

    expect(requestedSectors, [1, 2]);
    expect(find.text('B&DYS'), findsOneWidget);
  });

  testWidgets(
    'record expense success submits the request and refreshes the list',
    (WidgetTester tester) async {
      SaveExpenseRequest? sentRequest;
      fakeExpensesRepository.onRecordExpense = (request) async {
        sentRequest = request;
        return ExpenseRecord.fromJson(expenseJson);
      };

      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), '3500.75');
      await tester.enterText(find.byType(TextField).at(1), 'Office supplies');
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(sentRequest?.amount, 3500.75);
      expect(sentRequest?.description, 'Office supplies');
      expect(sentRequest?.sectorId, 1);
      expect(find.text('Expense recorded successfully.'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets('the Owner can change the sector and the list reloads', (
    WidgetTester tester,
  ) async {
    final List<int?> requestedSectors = <int?>[];
    fakeExpensesRepository.onGetExpenses = (sectorId) async {
      requestedSectors.add(sectorId);
      return buildExpensesList();
    };

    await pumpScreen(tester);
    expect(requestedSectors, [1]);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();

    expect(requestedSectors, [1, 2]);
  });

  testWidgets('the Event Manager sees a read-only sector and no sector_id '
      'is sent', (WidgetTester tester) async {
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(eventManagerUserJson);
    await authProvider.checkAuthStatus();

    final List<int?> requestedSectors = <int?>[];
    fakeExpensesRepository.onGetExpenses = (sectorId) async {
      requestedSectors.add(sectorId);
      return buildExpensesList();
    };
    SaveExpenseRequest? sentRequest;
    fakeExpensesRepository.onRecordExpense = (request) async {
      sentRequest = request;
      return ExpenseRecord.fromJson(expenseJson);
    };

    await pumpScreen(tester);

    expect(requestedSectors, [null]);
    expect(find.text('B&DYS'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '1200');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(sentRequest?.sectorId, isNull);
    expect(find.text('Expense recorded successfully.'), findsOneWidget);
    expect(find.text('Sector is required.'), findsNothing);
  });

  testWidgets('backend error while recording is displayed', (
    WidgetTester tester,
  ) async {
    fakeExpensesRepository.onRecordExpense = (_) async {
      throw Exception('Forbidden.');
    };

    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '1000');
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}

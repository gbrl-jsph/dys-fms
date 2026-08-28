import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/expenses/data/models/expense_record.dart';
import 'package:dys_fms/features/expenses/data/models/save_expense_request.dart';
import 'package:dys_fms/features/expenses/data/repositories/expenses_repository.dart';

import '../../helpers/fake_expenses_repository.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late ExpensesRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, tokenClearer: () async {}, httpClientAdapter: adapter);
    repository = ExpensesRepository(ApiClient.instance);
  });

  test('getExpenses() GETs /expenses without a sector filter and parses the '
      'list including payroll-generated records', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': [expenseJson, payrollExpenseJson],
        'message': 'Expenses retrieved successfully.',
      });
    };

    final List<ExpenseRecord> expenses = await repository.getExpenses();

    expect(captured?.path, '/expenses');
    expect(captured?.method, 'GET');
    expect(captured?.queryParameters, <String, dynamic>{});
    expect(expenses, hasLength(2));
    expect(expenses.first.id, 201);
    expect(expenses.first.amount, 5000.00);
    expect(expenses.first.description, 'Catering supplies');
    expect(expenses.first.recordedByName, 'Juan Dela Cruz');
    expect(expenses.first.sectorId, 1);
    expect(expenses.first.sectorName, 'DYS Events');
    expect(expenses.first.payrollRecordId, isNull);
    expect(expenses.last.payrollRecordId, 50);
    expect(expenses.last.description, 'Payroll — Maria Santos — 2026-07-15');
    expect(expenses.first.recordedAt.toUtc().hour, 15);
  });

  test(
    'getExpenses() includes sector_id when the Owner filters by sector',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': [expenseJson],
          'message': 'Expenses retrieved successfully.',
        });
      };

      await repository.getExpenses(sectorId: 2);

      expect(captured?.queryParameters, {'sector_id': 2});
    },
  );

  test('recordExpense() POSTs /expenses with amount, description, and '
      'sector_id', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(201, {
        'data': expenseJson,
        'message': 'Expense recorded successfully.',
      });
    };

    final ExpenseRecord record = await repository.recordExpense(
      const SaveExpenseRequest(
        amount: 3500,
        description: 'Office supplies',
        sectorId: 2,
      ),
    );

    expect(captured?.path, '/expenses');
    expect(captured?.method, 'POST');
    expect(captured?.data, {
      'amount': 3500,
      'description': 'Office supplies',
      'sector_id': 2,
    });
    expect(record.id, 201);
  });

  test(
    'recordExpense() omits description and sector_id for an Event Manager',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(201, {
          'data': expenseJson,
          'message': 'Expense recorded successfully.',
        });
      };

      await repository.recordExpense(const SaveExpenseRequest(amount: 1200));

      expect(captured?.data, {'amount': 1200});
    },
  );

  test('propagates the DioException on failure (403)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getExpenses(),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map<String, dynamic>)['message'],
          'message',
          'Forbidden.',
        ),
      ),
    );
  });
}

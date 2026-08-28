import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/events/financial_events.dart';
import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/expenses/data/models/save_expense_request.dart';
import 'package:dys_fms/features/expenses/data/repositories/expenses_repository.dart';
import 'package:dys_fms/features/expenses/domain/expenses_state.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';

import '../../helpers/fake_expenses_repository.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late ExpensesRepository repository;
  late ExpensesProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, tokenClearer: () async {}, httpClientAdapter: adapter);
    repository = ExpensesRepository(ApiClient.instance);
    provider = ExpensesProvider(repository);
  });

  test('loadExpenses() publishes loading then the loaded records', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': [expenseJson, payrollExpenseJson],
      'message': 'Expenses retrieved successfully.',
    });

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.expenses, isEmpty);

    final Future<void> load = provider.loadExpenses(sectorId: 1);

    expect(provider.state.isLoading, isTrue);

    await load;

    final ExpensesState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.expenses, hasLength(2));
    expect(state.expenses.first.amount, 5000.00);
    expect(state.expenses.first.sectorName, 'DYS Events');
  });

  test('loadExpenses() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.loadExpenses();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.error, 'Forbidden.');
    expect(provider.state.expenses, isEmpty);
  });

  test(
    'recordExpense() submits, refreshes the list, and publishes success',
    () async {
      SaveExpenseRequest? sentRequest;
      adapter.onRequest = (options) async {
        if (options.method == 'POST') {
          final Map<String, dynamic> body =
              options.data as Map<String, dynamic>;
          sentRequest = SaveExpenseRequest(
            amount: (body['amount'] as num).toDouble(),
            description: body['description'] as String?,
            sectorId: body['sector_id'] as int?,
          );
          return jsonResponse(201, {
            'data': expenseJson,
            'message': 'Expense recorded successfully.',
          });
        }
        return jsonResponse(200, {
          'data': [expenseJson],
          'message': 'Expenses retrieved successfully.',
        });
      };

      final Future<void> record = provider.recordExpense(
        const SaveExpenseRequest(
          amount: 5000,
          description: 'Catering supplies',
          sectorId: 1,
        ),
        sectorId: 1,
      );

      expect(provider.state.isSubmitting, isTrue);

      await record;

      final ExpensesState state = provider.state;
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
      expect(state.successMessage, 'Expense recorded successfully.');
      expect(state.expenses, hasLength(1));
      expect(sentRequest?.amount, 5000.00);
      expect(sentRequest?.sectorId, 1);
    },
  );

  test('recordExpense() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.recordExpense(const SaveExpenseRequest(amount: 0));

    expect(provider.state.isSubmitting, isFalse);
    expect(provider.state.successMessage, isNull);
    expect(provider.state.error, 'Forbidden.');
  });

  test('clearSuccess() and clearError() reset the feedback fields', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});
    await provider.loadExpenses();
    expect(provider.state.error, isNotNull);

    provider.clearError();
    expect(provider.state.error, isNull);

    adapter.onRequest = (options) async {
      if (options.method == 'POST') {
        return jsonResponse(201, {
          'data': expenseJson,
          'message': 'Expense recorded successfully.',
        });
      }
      return jsonResponse(200, {
        'data': [expenseJson],
        'message': 'Expenses retrieved successfully.',
      });
    };
    await provider.recordExpense(const SaveExpenseRequest(amount: 100));
    expect(provider.state.successMessage, isNotNull);

    provider.clearSuccess();
    expect(provider.state.successMessage, isNull);
  });

  test('propagates the DioException from the repository', () async {
    adapter.onRequest = (options) async =>
        throw DioException(requestOptions: RequestOptions(path: '/expenses'));

    await provider.loadExpenses();

    expect(provider.state.error, 'Something went wrong. Please try again.');
  });

  test('recordExpense() notifies financial events after a success', () async {
    final FinancialEvents events = FinancialEvents();
    int notifications = 0;
    events.addListener(() => notifications++);
    provider = ExpensesProvider(repository, financialEvents: events);

    adapter.onRequest = (options) async {
      if (options.method == 'POST') {
        return jsonResponse(201, {
          'data': expenseJson,
          'message': 'Expense recorded successfully.',
        });
      }
      return jsonResponse(200, {
        'data': [expenseJson],
        'message': 'Expenses retrieved successfully.',
      });
    };

    await provider.recordExpense(
      const SaveExpenseRequest(amount: 100, sectorId: 1),
    );

    expect(notifications, 1);
  });

  test('recordExpense() does not notify financial events on failure', () async {
    final FinancialEvents events = FinancialEvents();
    int notifications = 0;
    events.addListener(() => notifications++);
    provider = ExpensesProvider(repository, financialEvents: events);

    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.recordExpense(const SaveExpenseRequest(amount: 100));

    expect(provider.state.error, 'Forbidden.');
    expect(notifications, 0);
  });
}

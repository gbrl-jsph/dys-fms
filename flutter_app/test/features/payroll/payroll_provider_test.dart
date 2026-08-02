import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/payroll/data/models/save_payroll_request.dart';
import 'package:dys_fms/features/payroll/data/repositories/payroll_repository.dart';
import 'package:dys_fms/features/payroll/domain/payroll_state.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_payroll_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late PayrollRepository repository;
  late PayrollProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = PayrollRepository(ApiClient.instance);
    provider = PayrollProvider(repository);
  });

  test('loadPayroll() publishes loading then the loaded records', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': [payrollJson, secondPayrollJson],
      'message': 'Payroll records retrieved successfully.',
    });

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.records, isEmpty);

    final Future<void> load = provider.loadPayroll(sectorId: 1);

    expect(provider.state.isLoading, isTrue);

    await load;

    final PayrollState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.records, hasLength(2));
    expect(state.records.first.computedSalary, 20000.00);
    expect(state.records.first.employeeName, 'Ana Gomez');
  });

  test('loadPayroll() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.loadPayroll();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.error, 'Forbidden.');
    expect(provider.state.records, isEmpty);
  });

  test(
    'calculatePayroll() submits, refreshes the list, and publishes success',
    () async {
      SavePayrollRequest? sentRequest;
      adapter.onRequest = (options) async {
        if (options.method == 'POST') {
          final Map<String, dynamic> body =
              options.data as Map<String, dynamic>;
          sentRequest = SavePayrollRequest(
            userId: body['user_id'] as int,
            hoursWorked: (body['hours_worked'] as num).toDouble(),
            hourlyRate: (body['hourly_rate'] as num).toDouble(),
            payPeriod: DateTime.parse(body['pay_period'] as String),
          );
          return jsonResponse(201, {
            'data': payrollJson,
            'message':
                'Payroll calculated and saved successfully. Expense '
                'record auto-created.',
          });
        }
        return jsonResponse(200, {
          'data': [payrollJson],
          'message': 'Payroll records retrieved successfully.',
        });
      };

      final Future<void> calculate = provider.calculatePayroll(
        SavePayrollRequest(
          userId: 3,
          hoursWorked: 160.00,
          hourlyRate: 125.00,
          payPeriod: DateTime(2026, 7, 15),
        ),
        sectorId: 1,
      );

      expect(provider.state.isSubmitting, isTrue);

      await calculate;

      final PayrollState state = provider.state;
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
      expect(
        state.successMessage,
        'Payroll calculated and saved successfully. Expense record '
        'auto-created.',
      );
      expect(state.records, hasLength(1));
      expect(sentRequest?.userId, 3);
      expect(sentRequest?.hoursWorked, 160.00);
      expect(sentRequest?.hourlyRate, 125.00);
      expect(sentRequest?.payPeriod.day, 15);
    },
  );

  test('calculatePayroll() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.calculatePayroll(
      SavePayrollRequest(
        userId: 3,
        hoursWorked: 160,
        hourlyRate: 125,
        payPeriod: DateTime(2026, 7, 15),
      ),
    );

    expect(provider.state.isSubmitting, isFalse);
    expect(provider.state.successMessage, isNull);
    expect(provider.state.error, 'Forbidden.');
  });

  test('clearSuccess() and clearError() reset the feedback fields', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});
    await provider.loadPayroll();
    expect(provider.state.error, isNotNull);

    provider.clearError();
    expect(provider.state.error, isNull);

    adapter.onRequest = (options) async {
      if (options.method == 'POST') {
        return jsonResponse(201, {
          'data': payrollJson,
          'message': 'Payroll calculated and saved successfully.',
        });
      }
      return jsonResponse(200, {
        'data': [payrollJson],
        'message': 'Payroll records retrieved successfully.',
      });
    };
    await provider.calculatePayroll(
      SavePayrollRequest(
        userId: 3,
        hoursWorked: 160,
        hourlyRate: 125,
        payPeriod: DateTime(2026, 7, 15),
      ),
    );
    expect(provider.state.successMessage, isNotNull);

    provider.clearSuccess();
    expect(provider.state.successMessage, isNull);
  });

  test('propagates the DioException from the repository', () async {
    adapter.onRequest = (options) async =>
        throw DioException(requestOptions: RequestOptions(path: '/payroll'));

    await provider.loadPayroll();

    expect(provider.state.error, 'Something went wrong. Please try again.');
  });
}

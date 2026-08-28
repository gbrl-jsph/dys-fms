import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/payroll/data/models/payroll_record.dart';
import 'package:dys_fms/features/payroll/data/models/save_payroll_request.dart';
import 'package:dys_fms/features/payroll/data/repositories/payroll_repository.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_payroll_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late PayrollRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, tokenClearer: () async {}, httpClientAdapter: adapter);
    repository = PayrollRepository(ApiClient.instance);
  });

  test('getPayroll() GETs /payroll without filters and parses the records '
      'including nested employee/sector and the linked expense id', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': [payrollJson, secondPayrollJson],
        'message': 'Payroll records retrieved successfully.',
      });
    };

    final List<PayrollRecord> records = await repository.getPayroll();

    expect(captured?.path, '/payroll');
    expect(captured?.method, 'GET');
    expect(captured?.queryParameters, <String, dynamic>{});
    expect(records, hasLength(2));
    expect(records.first.id, 50);
    expect(records.first.employeeId, 3);
    expect(records.first.employeeName, 'Ana Gomez');
    expect(records.first.sectorId, 1);
    expect(records.first.sectorName, 'DYS Events');
    expect(records.first.hoursWorked, 160.00);
    expect(records.first.hourlyRate, 125.00);
    expect(records.first.computedSalary, 20000.00);
    expect(records.first.payPeriod.day, 15);
    expect(records.first.calculatedAt.toUtc().hour, 16);
    expect(records.first.expenseId, 202);
    expect(records.last.expenseId, 203);
  });

  test(
    'getPayroll() includes sector_id when the Owner filters by sector',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': [payrollJson],
          'message': 'Payroll records retrieved successfully.',
        });
      };

      await repository.getPayroll(sectorId: 2);

      expect(captured?.queryParameters, {'sector_id': 2});
    },
  );

  test('calculatePayroll() POSTs /payroll with user_id, hours_worked, '
      'hourly_rate, and a YYYY-MM-DD pay_period (no client-computed '
      'salary or sector)', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(201, {
        'data': payrollJson,
        'message':
            'Payroll calculated and saved successfully. Expense '
            'record auto-created.',
      });
    };

    await repository.calculatePayroll(
      SavePayrollRequest(
        userId: 3,
        hoursWorked: 160.00,
        hourlyRate: 125.00,
        payPeriod: DateTime(2026, 7, 15),
      ),
    );

    expect(captured?.path, '/payroll');
    expect(captured?.method, 'POST');
    expect(captured?.data, {
      'user_id': 3,
      'hours_worked': 160.00,
      'hourly_rate': 125.00,
      'pay_period': '2026-07-15',
    });
  });

  test(
    'calculatePayroll() parses the created record from the response',
    () async {
      adapter.onRequest = (options) async => jsonResponse(201, {
        'data': secondPayrollJson,
        'message': 'Payroll calculated and saved successfully.',
      });

      final PayrollRecord record = await repository.calculatePayroll(
        SavePayrollRequest(
          userId: 2,
          hoursWorked: 80.00,
          hourlyRate: 150.00,
          payPeriod: DateTime(2026, 7, 15),
        ),
      );

      expect(record.id, 51);
      expect(record.employeeName, 'Maria Santos');
      expect(record.computedSalary, 12000.00);
      expect(record.expenseId, 203);
    },
  );

  test('propagates the DioException on failure (403)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getPayroll(),
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

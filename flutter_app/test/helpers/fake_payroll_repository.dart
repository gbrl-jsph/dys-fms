import 'package:dio/dio.dart';

import 'package:dys_fms/features/payroll/data/models/payroll_record.dart';
import 'package:dys_fms/features/payroll/data/models/save_payroll_request.dart';
import 'package:dys_fms/features/payroll/data/repositories/payroll_repository.dart';

/// Sample payroll payloads matching the API spec `data` array.
const Map<String, dynamic> payrollJson = {
  'id': 50,
  'employee': {'id': 3, 'name': 'Ana Gomez'},
  'sector': {'id': 1, 'name': 'DYS Events'},
  'hours_worked': 160.00,
  'hourly_rate': 125.00,
  'computed_salary': 20000.00,
  'pay_period': '2026-07-15',
  'calculated_at': '2026-07-28T16:00:00.000000Z',
  'expense': {'id': 202, 'amount': 20000.00},
};

const Map<String, dynamic> secondPayrollJson = {
  'id': 51,
  'employee': {'id': 2, 'name': 'Maria Santos'},
  'sector': {'id': 2, 'name': 'B&DYS'},
  'hours_worked': 80.00,
  'hourly_rate': 150.00,
  'computed_salary': 12000.00,
  'pay_period': '2026-07-15',
  'calculated_at': '2026-07-28T18:00:00.000000Z',
  'expense': {'id': 203, 'amount': 12000.00},
};

List<PayrollRecord> buildPayrollList() => [
  PayrollRecord.fromJson(payrollJson),
  PayrollRecord.fromJson(secondPayrollJson),
];

/// In-memory [PayrollRepository] fake with overridable callbacks.
class FakePayrollRepository implements PayrollRepository {
  Future<List<PayrollRecord>> Function(int? sectorId)? onGetPayroll;
  Future<PayrollRecord> Function(SavePayrollRequest request)?
  onCalculatePayroll;

  @override
  late final Dio dio = Dio();

  @override
  Future<List<PayrollRecord>> getPayroll({int? sectorId}) =>
      onGetPayroll!(sectorId);

  @override
  Future<PayrollRecord> calculatePayroll(SavePayrollRequest request) =>
      onCalculatePayroll!(request);
}

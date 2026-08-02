import 'package:dio/dio.dart';

import 'package:dys_fms/features/expenses/data/models/expense_record.dart';
import 'package:dys_fms/features/expenses/data/models/save_expense_request.dart';
import 'package:dys_fms/features/expenses/data/repositories/expenses_repository.dart';

/// Sample expense payloads matching the API spec `data` array.
const Map<String, dynamic> expenseJson = {
  'id': 201,
  'amount': 5000.00,
  'description': 'Catering supplies',
  'recorded_by': {'id': 1, 'name': 'Juan Dela Cruz'},
  'sector': {'id': 1, 'name': 'DYS Events'},
  'payroll_record_id': null,
  'recorded_at': '2026-07-28T15:30:00.000000Z',
};

const Map<String, dynamic> payrollExpenseJson = {
  'id': 202,
  'amount': 20000.00,
  'description': 'Payroll — Maria Santos — 2026-07-15',
  'recorded_by': {'id': 1, 'name': 'Juan Dela Cruz'},
  'sector': {'id': 1, 'name': 'DYS Events'},
  'payroll_record_id': 50,
  'recorded_at': '2026-07-28T16:00:00.000000Z',
};

List<ExpenseRecord> buildExpensesList() => [
  ExpenseRecord.fromJson(expenseJson),
  ExpenseRecord.fromJson(payrollExpenseJson),
];

/// In-memory [ExpensesRepository] fake with overridable callbacks.
class FakeExpensesRepository implements ExpensesRepository {
  Future<List<ExpenseRecord>> Function(int? sectorId)? onGetExpenses;
  Future<ExpenseRecord> Function(SaveExpenseRequest request)? onRecordExpense;

  @override
  late final Dio dio = Dio();

  @override
  Future<List<ExpenseRecord>> getExpenses({int? sectorId}) =>
      onGetExpenses!(sectorId);

  @override
  Future<ExpenseRecord> recordExpense(SaveExpenseRequest request) =>
      onRecordExpense!(request);
}

import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/expense_record.dart';
import '../models/save_expense_request.dart';

/// Expense data operations (Phase 3, FR-005).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class ExpensesRepository extends Repository {
  ExpensesRepository(super.apiClient);

  /// GET /api/expenses — list expense records.
  ///
  /// [sectorId] filters to one sector (Business Owner only per the API
  /// spec; the Event Manager is always scoped to the assigned sector by
  /// the server, so the parameter is omitted for that role).
  Future<List<ExpenseRecord>> getExpenses({int? sectorId}) async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.expensesEndpoint,
      queryParameters: {'sector_id': ?sectorId},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;

    return list
        .map(
          (dynamic item) =>
              ExpenseRecord.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// POST /api/expenses — record a manual expense. The server assigns
  /// `user_id`, `recorded_at`, and `payroll_record_id = null`.
  Future<ExpenseRecord> recordExpense(SaveExpenseRequest request) async {
    final dynamic response = await dio.post<dynamic>(
      ApiConfig.expensesEndpoint,
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return ExpenseRecord.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ExpenseRecord> getExpense(int id) async {
    final dynamic response = await dio.get<dynamic>(ApiConfig.expenseEndpoint(id));
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    return ExpenseRecord.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ExpenseRecord> updateExpense(int id, SaveExpenseRequest request) async {
    final dynamic response = await dio.put<dynamic>(
      ApiConfig.expenseEndpoint(id),
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    return ExpenseRecord.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    await dio.delete<dynamic>(ApiConfig.expenseEndpoint(id));
  }

  Future<List<ExpenseRecord>> searchExpenses({
    int? sectorId,
    String? search,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
  }) async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.expensesEndpoint,
      queryParameters: {
        'sector_id': ?sectorId,
        'search': ?search,
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'amount_min': ?amountMin,
        'amount_max': ?amountMax,
      },
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;
    return list
        .map(
          (dynamic item) => ExpenseRecord.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}

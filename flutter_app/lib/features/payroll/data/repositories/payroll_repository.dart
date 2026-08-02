import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/payroll_record.dart';
import '../models/save_payroll_request.dart';

/// Payroll data operations (Phase 5, FR-006).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class PayrollRepository extends Repository {
  PayrollRepository(super.apiClient);

  /// GET /api/payroll — list payroll records.
  ///
  /// All roles are allowed; the server scopes Event Managers and
  /// Employees to their own records. [sectorId] is an optional filter
  /// for the Business Owner only (ignored for other roles).
  Future<List<PayrollRecord>> getPayroll({int? sectorId}) async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.payrollEndpoint,
      queryParameters: {'sector_id': ?sectorId},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;

    return list
        .map(
          (dynamic item) =>
              PayrollRecord.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// POST /api/payroll — calculate and save a payroll record.
  ///
  /// Business Owner only; the server computes the salary and auto-creates
  /// the linked Expense record in the same transaction.
  Future<PayrollRecord> calculatePayroll(SavePayrollRequest request) async {
    final dynamic response = await dio.post<dynamic>(
      ApiConfig.payrollEndpoint,
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return PayrollRecord.fromJson(body['data'] as Map<String, dynamic>);
  }
}

import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/financial_summary.dart';

/// Dashboard data operations (Phase 8, FR-002).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class DashboardRepository extends Repository {
  DashboardRepository(super.apiClient);

  /// GET /api/reports?type=summary — financial summary for the stat cards.
  ///
  /// [sectorId] filters to one sector (Business Owner only per the API
  /// spec; the Event Manager is always scoped to the assigned sector by
  /// the server). When omitted for an Owner, the server returns the
  /// cross-sector aggregate.
  Future<FinancialSummary> getSummary({int? sectorId}) async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.reportsEndpoint,
      queryParameters: {'type': 'summary', 'sector_id': ?sectorId},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return FinancialSummary.fromJson(body['data'] as Map<String, dynamic>);
  }
}

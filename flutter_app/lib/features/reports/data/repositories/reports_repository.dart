import '../../../../core/utils/formatters.dart';
import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/report_data.dart';

/// Report data operations (Phase 6, FR-007).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class ReportsRepository extends Repository {
  ReportsRepository(super.apiClient);

  /// GET /api/reports — generate a report for [type] (summary, sales,
  /// expenses, analytics) with an optional date range and sector filter.
  ///
  /// [sectorId] is the Business Owner's optional sector filter (when
  /// omitted the server returns the cross-sector aggregate); it is
  /// omitted for the Event Manager, who is scoped to the assigned sector
  /// by the server.
  Future<ReportData> getReport({
    required String type,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? sectorId,
  }) async {
    final String? dateFromValue = dateFrom == null
        ? null
        : Formatters.formatApiDate(dateFrom);
    final String? dateToValue = dateTo == null
        ? null
        : Formatters.formatApiDate(dateTo);

    final dynamic response = await dio.get<dynamic>(
      ApiConfig.reportsEndpoint,
      queryParameters: {
        'type': type,
        'date_from': ?dateFromValue,
        'date_to': ?dateToValue,
        'sector_id': ?sectorId,
      },
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return ReportData.fromJson(body['data'] as Map<String, dynamic>);
  }
}

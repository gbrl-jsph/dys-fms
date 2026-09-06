import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/financial_summary.dart';
import '../models/recent_transaction.dart';

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

  /// Loads the newest sales and expenses using the existing authorized list
  /// endpoints. The server still enforces the caller's role and sector scope.
  Future<List<RecentTransaction>> getRecentTransactions({int? sectorId}) async {
    final Map<String, dynamic> query = {
      'sector_id': ?sectorId,
      'per_page': 6,
    };
    final List<dynamic> responses = await Future.wait<dynamic>([
      dio.get<dynamic>(ApiConfig.salesEndpoint, queryParameters: query),
      dio.get<dynamic>(ApiConfig.expensesEndpoint, queryParameters: query),
    ]);
    final List<RecentTransaction> transactions = [
      for (final Map<String, dynamic> sale
          in (responses[0].data as Map<String, dynamic>)['data'] as List<dynamic>)
        RecentTransaction.sale(sale),
      for (final Map<String, dynamic> expense
          in (responses[1].data as Map<String, dynamic>)['data'] as List<dynamic>)
        RecentTransaction.expense(expense),
    ]..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return transactions.take(6).toList();
  }
}

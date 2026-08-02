import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/save_sale_request.dart';
import '../models/sales_transaction.dart';

/// Sales data operations (Phase 3, FR-004).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class SalesRepository extends Repository {
  SalesRepository(super.apiClient);

  /// GET /api/sales — list sales transactions.
  ///
  /// [sectorId] filters to one sector (Business Owner only per the API
  /// spec; the Event Manager is always scoped to the assigned sector by
  /// the server, so the parameter is omitted for that role).
  Future<List<SalesTransaction>> getSales({int? sectorId}) async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.salesEndpoint,
      queryParameters: {'sector_id': ?sectorId},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;

    return list
        .map(
          (dynamic item) =>
              SalesTransaction.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// POST /api/sales — record a new sales transaction. The server assigns
  /// `user_id` and `recorded_at`; sales are immutable after creation.
  Future<SalesTransaction> recordSale(SaveSaleRequest request) async {
    final dynamic response = await dio.post<dynamic>(
      ApiConfig.salesEndpoint,
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return SalesTransaction.fromJson(body['data'] as Map<String, dynamic>);
  }
}

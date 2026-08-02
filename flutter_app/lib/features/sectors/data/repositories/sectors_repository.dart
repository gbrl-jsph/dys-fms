import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/business_sector.dart';

/// Business sector data operations (Phase 7, FR-008).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class SectorsRepository extends Repository {
  SectorsRepository(super.apiClient);

  /// GET /api/business-sectors — list the four approved sectors.
  ///
  /// Available to all authenticated roles.
  Future<List<BusinessSector>> getSectors() async {
    final dynamic response = await dio.get<dynamic>(
      ApiConfig.businessSectorsEndpoint,
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;

    return list
        .map(
          (dynamic item) =>
              BusinessSector.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// POST /api/business-sectors/switch — switch the current sector
  /// context.
  ///
  /// Business Owner only (the server returns 403 for other roles). The
  /// switch is stateless on the server; the response acknowledges it
  /// with the previous and current sector so the client can update its
  /// sector context (FR-008).
  Future<SectorSwitchResult> switchSector(int sectorId) async {
    final dynamic response = await dio.post<dynamic>(
      ApiConfig.businessSectorsSwitchEndpoint,
      data: {'sector_id': sectorId},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return SectorSwitchResult.fromJson(body['data'] as Map<String, dynamic>);
  }
}

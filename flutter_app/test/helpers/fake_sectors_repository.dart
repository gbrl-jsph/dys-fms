import 'package:dio/dio.dart';

import 'package:dys_fms/features/sectors/data/models/business_sector.dart';
import 'package:dys_fms/features/sectors/data/repositories/sectors_repository.dart';

/// Sample GET /business-sectors payload matching the API spec `data`.
const List<Map<String, dynamic>> businessSectorsJson = [
  {
    'id': 1,
    'name': 'DYS Events',
    'description': 'Event coordination and styling main branch',
  },
  {'id': 2, 'name': 'B&DYS', 'description': 'Souvenirs'},
  {
    'id': 3,
    'name': 'Flavors by DYS',
    'description': 'Grazing tables and celebration drinks',
  },
  {'id': 4, 'name': 'SnapDYS Memories', 'description': 'Video guestbook'},
];

/// Sample POST /business-sectors/switch payload matching the API spec
/// `data` (switching from DYS Events to B&DYS).
const Map<String, dynamic> switchSectorResponseJson = {
  'previous_sector': {'id': 1, 'name': 'DYS Events'},
  'current_sector': {'id': 2, 'name': 'B&DYS'},
};

List<BusinessSector> buildSectorsList() => businessSectorsJson
    .map((Map<String, dynamic> json) => BusinessSector.fromJson(json))
    .toList();

SectorSwitchResult buildSwitchResult() =>
    SectorSwitchResult.fromJson(switchSectorResponseJson);

/// In-memory [SectorsRepository] fake with overridable callbacks.
class FakeSectorsRepository implements SectorsRepository {
  Future<List<BusinessSector>> Function()? onGetSectors;
  Future<SectorSwitchResult> Function(int sectorId)? onSwitchSector;

  @override
  late final Dio dio = Dio();

  @override
  Future<List<BusinessSector>> getSectors() => onGetSectors!();

  @override
  Future<SectorSwitchResult> switchSector(int sectorId) =>
      onSwitchSector!(sectorId);
}

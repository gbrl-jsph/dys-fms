/// A business sector from `GET /api/business-sectors`.
///
/// Mirrors the `business_sectors` table; the description is present in
/// the list response but omitted from the switch acknowledgement.
class BusinessSector {
  const BusinessSector({
    required this.id,
    required this.name,
    this.description,
  });

  factory BusinessSector.fromJson(Map<String, dynamic> json) => BusinessSector(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
  );

  final int id;
  final String name;
  final String? description;
}

/// Successful `POST /api/business-sectors/switch` response, parsed from
/// the nested `data` object.
///
/// The server acknowledges the switch with both sectors so the client
/// can synchronize its sector context (FR-008).
class SectorSwitchResult {
  const SectorSwitchResult({
    required this.previousSector,
    required this.currentSector,
  });

  factory SectorSwitchResult.fromJson(Map<String, dynamic> json) =>
      SectorSwitchResult(
        previousSector: BusinessSector.fromJson(
          json['previous_sector'] as Map<String, dynamic>,
        ),
        currentSector: BusinessSector.fromJson(
          json['current_sector'] as Map<String, dynamic>,
        ),
      );

  final BusinessSector previousSector;
  final BusinessSector currentSector;
}

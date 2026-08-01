/// The four approved business sectors (seeded per API Specification and
/// BusinessSectorSeeder). Used to populate the Sector dropdown on the
/// User Account Management screen until the Phase 7 /business-sectors
/// endpoint is implemented.
class BusinessSectorsConfig {
  BusinessSectorsConfig._();

  static const List<BusinessSectorData> sectors = [
    BusinessSectorData(
      id: 1,
      name: 'DYS Events',
      description: 'Event coordination and styling main branch',
    ),
    BusinessSectorData(
      id: 2,
      name: 'B&DYS',
      description: 'Souvenirs',
    ),
    BusinessSectorData(
      id: 3,
      name: 'Flavors by DYS',
      description: 'Grazing tables and celebration drinks',
    ),
    BusinessSectorData(
      id: 4,
      name: 'SnapDYS Memories',
      description: 'Video guestbook',
    ),
  ];
}

/// Static sector entry mirroring the `business_sectors` table columns.
class BusinessSectorData {
  const BusinessSectorData({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The four approved business sectors (seeded per API Specification and
/// BusinessSectorSeeder). Used to populate the Sector dropdown on the
/// User Account Management screen until the Phase 7 /business-sectors
/// endpoint is implemented, and to resolve sector display names/colors
/// on the Dashboard (Screen 2).
class BusinessSectorsConfig {
  BusinessSectorsConfig._();

  static const List<BusinessSectorData> sectors = [
    BusinessSectorData(
      id: 1,
      name: 'DYS Events',
      description: 'Event coordination and styling main branch',
      accent: AppColors.sectorEvents,
      accentContainer: AppColors.sectorEventsContainer,
    ),
    BusinessSectorData(
      id: 2,
      name: 'B&DYS',
      description: 'Souvenirs',
      accent: AppColors.sectorBDys,
      accentContainer: AppColors.sectorBDysContainer,
    ),
    BusinessSectorData(
      id: 3,
      name: 'Flavors by DYS',
      description: 'Grazing tables and celebration drinks',
      accent: AppColors.sectorFlavors,
      accentContainer: AppColors.sectorFlavorsContainer,
    ),
    BusinessSectorData(
      id: 4,
      name: 'SnapDYS Memories',
      description: 'Video guestbook',
      accent: AppColors.sectorSnapDys,
      accentContainer: AppColors.sectorSnapDysContainer,
    ),
  ];

  /// Display name for a sector id, falling back to [fallback] when unknown.
  static String nameFor(int? id, {String fallback = '—'}) {
    if (id == null) return fallback;
    for (final BusinessSectorData sector in sectors) {
      if (sector.id == id) return sector.name;
    }
    return fallback;
  }

  /// Sector signature accent color for a sector id (UI Style Guide
  /// Color Palette), falling back to [fallback] when unknown.
  static Color accentFor(int? id, {Color fallback = AppColors.primary}) {
    if (id == null) return fallback;
    for (final BusinessSectorData sector in sectors) {
      if (sector.id == id) return sector.accent;
    }
    return fallback;
  }
}

/// Static sector entry mirroring the `business_sectors` table columns.
class BusinessSectorData {
  const BusinessSectorData({
    required this.id,
    required this.name,
    required this.accent,
    required this.accentContainer,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  /// Sector signature accent color (UI Style Guide Color Palette).
  final Color accent;

  /// Sector signature container (background) color.
  final Color accentContainer;
}

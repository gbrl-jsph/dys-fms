import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The four approved business sectors (seeded per API Specification and
/// BusinessSectorSeeder). Used to populate the Sector dropdown on the
/// User Account Management screen until the Phase 7 /business-sectors
/// endpoint is implemented, and to resolve sector display names/colors
/// on the Dashboard (Screen 2).
class BusinessSectorsConfig {
  BusinessSectorsConfig._();

  /// Rebuilt on each access so the signature accents resolve against the
  /// active color palette (light / dark) instead of freezing at first use.
  static List<BusinessSectorData> get sectors => [
    BusinessSectorData(
      id: 1,
      name: 'DYS Events',
      description: 'Event coordination and styling main branch',
      accent: AppColors.sectorEvents,
      accentContainer: AppColors.sectorEventsContainer,
      logoAsset: 'assets/sectors/sector_dys_events.jpg',
    ),
    BusinessSectorData(
      id: 2,
      name: 'B&DYS',
      description: 'Souvenirs',
      accent: AppColors.sectorBDys,
      accentContainer: AppColors.sectorBDysContainer,
      logoAsset: 'assets/sectors/sector_bandys.jpg',
    ),
    BusinessSectorData(
      id: 3,
      name: 'Flavors by DYS',
      description: 'Grazing tables and celebration drinks',
      accent: AppColors.sectorFlavors,
      accentContainer: AppColors.sectorFlavorsContainer,
      logoAsset: 'assets/sectors/sector_flavors.jpg',
    ),
    BusinessSectorData(
      id: 4,
      name: 'SnapDYS Memories',
      description: 'Video guestbook',
      accent: AppColors.sectorSnapDys,
      accentContainer: AppColors.sectorSnapDysContainer,
      logoAsset: 'assets/sectors/sector_snapdys.jpg',
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
  static Color accentFor(int? id, {Color? fallback}) {
    if (id == null) return fallback ?? AppColors.palette.primary;
    for (final BusinessSectorData sector in sectors) {
      if (sector.id == id) return sector.accent;
    }
    return fallback ?? AppColors.palette.primary;
  }

  /// Sector logo asset path for a sector id, falling back to an empty
  /// string when the sector is unknown (the logo widget then renders its
  /// icon fallback).
  static String logoAssetFor(int? id) {
    if (id == null) return '';
    for (final BusinessSectorData sector in sectors) {
      if (sector.id == id) return sector.logoAsset;
    }
    return '';
  }

  /// Per-sector icon fallback (sector-switcher.html wireframe), used by
  /// the logo widget and the switcher cards when no logo is available.
  static IconData iconFor(int? id) {
    switch (id) {
      case 2:
        return Icons.card_giftcard;
      case 3:
        return Icons.local_cafe_outlined;
      case 4:
        return Icons.videocam_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
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
    this.logoAsset = '',
  });

  final int id;
  final String name;
  final String? description;

  /// Sector signature accent color (UI Style Guide Color Palette).
  final Color accent;

  /// Sector signature container (background) color.
  final Color accentContainer;

  /// Bundled sector logo asset path; empty when unavailable.
  final String logoAsset;
}

import 'package:flutter/material.dart';

import '../constants/business_sectors.dart';

/// Circular sector logo thumbnail.
///
/// Renders the bundled logo asset for the sector id with [BoxFit.cover]
/// at a consistent [size]. When the asset is missing or fails to load,
/// it falls back to the wireframe per-sector icon on the signature
/// accent container so the UI never shows a broken image.
class SectorLogo extends StatelessWidget {
  const SectorLogo({super.key, required this.sectorId, this.size = 40});

  final int? sectorId;

  /// Diameter of the logo circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color accent = BusinessSectorsConfig.accentFor(sectorId);
    final String asset = BusinessSectorsConfig.logoAssetFor(sectorId);
    final Widget fallback = _iconFallback(accent);

    final Widget content;
    if (asset.isEmpty) {
      content = fallback;
    } else {
      content = ClipOval(
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? st) =>
              fallback,
        ),
      );
    }

    return SizedBox(width: size, height: size, child: content);
  }

  Widget _iconFallback(Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        BusinessSectorsConfig.iconFor(sectorId),
        size: size * 0.5,
        color: accent,
      ),
    );
  }
}

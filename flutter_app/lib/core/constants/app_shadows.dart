import 'package:flutter/material.dart';

/// Elevation / shadow tokens (ui-style-guide.md: Elevation / Shadows).
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x0F14142B), // rgba(20,20,43,0.06)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x1414142B), // rgba(20,20,43,0.08)
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x1A14142B), // rgba(20,20,43,0.10)
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x0F14142B), // rgba(20,20,43,0.06)
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> shadowCta = [
    BoxShadow(
      color: Color(0x474338CA), // rgba(67,56,202,0.28)
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];
}

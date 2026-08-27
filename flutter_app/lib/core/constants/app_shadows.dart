import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevation / shadow tokens (ui-style-guide.md: Elevation / Shadows).
///
/// The light values come from the style guide; dark-mode variants use
/// near-black shadows so elevation stays visible on dark surfaces.
/// Getters resolve against [AppColors.brightness] like every other
/// color token, keeping call sites identical in both modes.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> _shadow1Light = [
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

  static const List<BoxShadow> _shadow1Dark = [
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,0.30)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x66000000), // rgba(0,0,0,0.40)
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> _shadow2Light = [
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

  static const List<BoxShadow> _shadow2Dark = [
    BoxShadow(
      color: Color(0x66000000), // rgba(0,0,0,0.40)
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,0.30)
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> _shadowCtaLight = [
    BoxShadow(
      color: Color(0x47D4AF37), // gold, rgba(212,175,55,0.28)
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> _shadowCtaDark = [
    BoxShadow(
      color: Color(0x59D4AF37), // gold, rgba(212,175,55,0.35)
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  static List<BoxShadow> get shadow1 =>
      AppColors.brightness == Brightness.dark ? _shadow1Dark : _shadow1Light;

  static List<BoxShadow> get shadow2 =>
      AppColors.brightness == Brightness.dark ? _shadow2Dark : _shadow2Light;

  static List<BoxShadow> get shadowCta =>
      AppColors.brightness == Brightness.dark
      ? _shadowCtaDark
      : _shadowCtaLight;
}

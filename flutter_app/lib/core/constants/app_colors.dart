import 'package:flutter/material.dart';

/// Color tokens from the UI Style Guide (ui-style-guide.md: Color Palette).
///
/// 14 base tokens + 5 sector signature color pairs + chart series colors.
class AppColors {
  AppColors._();

  // Brand & Semantic
  static const Color primary = Color(0xFF4338CA);
  static const Color primaryHover = Color(0xFF372DAA);
  static const Color primaryContainer = Color(0xFFEEEDFC);
  static const Color primaryContainerInk = Color(0xFF2E249B);
  static const Color success = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFE7F6EC);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerContainer = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFDF3E3);

  // Neutral Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7F7FA);
  static const Color surfaceSunken = Color(0xFFF0F1F5);
  static const Color border = Color(0xFFE4E4EA);
  static const Color borderStrong = Color(0xFFD2D3DB);

  // Text
  static const Color ink = Color(0xFF1C1B22);
  static const Color inkSecondary = Color(0xFF5B5C66);
  static const Color inkMuted = Color(0xFF8B8C97);
  static const Color inkOnPrimary = Color(0xFFFFFFFF);

  // Sector Signature Colors (accent / background)
  static const Color sectorEvents = Color(0xFF7C3AED);
  static const Color sectorEventsContainer = Color(0xFFF3ECFD);
  static const Color sectorBDys = Color(0xFFB45309);
  static const Color sectorBDysContainer = Color(0xFFFDF3E3);
  static const Color sectorFlavors = Color(0xFF15803D);
  static const Color sectorFlavorsContainer = Color(0xFFE7F6EC);
  static const Color sectorSnapDys = Color(0xFF2563EB);
  static const Color sectorSnapDysContainer = Color(0xFFE9F0FE);

  // Chart Series Colors
  static const Color totalSales = primary;
  static const Color totalExpenses = danger;
  static const Color netBalance = success;
}

import 'package:flutter/material.dart';

/// Light and dark color token palettes for the black + gold branding.
///
/// 14 base tokens + 5 sector signature color pairs + chart series colors.
/// Tokens are resolved at runtime against the active [AppColors.brightness]
/// so widgets keep referencing `AppColors.*` regardless of the theme mode;
/// the dark palette mirrors the approved light tokens with darkened
/// near-black surfaces and lightened text for contrast.
class AppColors {
  AppColors._();

  /// Active brightness, set by the app root before every build so widget
  /// reads stay in sync with the ThemeMode selection.
  static Brightness brightness = Brightness.light;

  /// Updates the active [brightness] used by the token getters.
  static void setBrightness(Brightness value) => brightness = value;

  /// The palette matching [brightness].
  static Palette get palette =>
      brightness == Brightness.dark ? darkPalette : lightPalette;

  /// Light palette: white/light surfaces, near-black text, gold accent.
  static const Palette lightPalette = Palette(
    primary: Color(0xFFD4AF37),
    primaryHover: Color(0xFFC2A22B),
    primaryContainer: Color(0xFFF8F0D4),
    primaryContainerInk: Color(0xFF6B5309),
    success: Color(0xFF15803D),
    successContainer: Color(0xFFE7F6EC),
    danger: Color(0xFFDC2626),
    dangerContainer: Color(0xFFFDECEC),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFDF3E3),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF7F7F4),
    surfaceSunken: Color(0xFFF0EFE8),
    border: Color(0xFFE7E5DC),
    borderStrong: Color(0xFFD4D2C3),
    ink: Color(0xFF1C1B16),
    inkSecondary: Color(0xFF5C5B50),
    inkMuted: Color(0xFF8C8B7E),
    inkOnPrimary: Color(0xFF1C1B16),
    sectorEvents: Color(0xFF7C3AED),
    sectorEventsContainer: Color(0xFFF3ECFD),
    sectorBDys: Color(0xFFB45309),
    sectorBDysContainer: Color(0xFFFDF3E3),
    sectorFlavors: Color(0xFF15803D),
    sectorFlavorsContainer: Color(0xFFE7F6EC),
    sectorSnapDys: Color(0xFF2563EB),
    sectorSnapDysContainer: Color(0xFFE9F0FE),
  );

  /// Dark-mode variant: same token names, near-black surfaces and light
  /// ink so the same screens remain readable without any widget
  /// duplication.
  static const Palette darkPalette = Palette(
    primary: Color(0xFFD4AF37),
    primaryHover: Color(0xFFC2A22B),
    primaryContainer: Color(0xFF2E2814),
    primaryContainerInk: Color(0xFFE8D48A),
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF123521),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF431517),
    warning: Color(0xFFF59E0B),
    warningContainer: Color(0xFF3B2A12),
    surface: Color(0xFF1A1A1A),
    surfaceAlt: Color(0xFF121212),
    surfaceSunken: Color(0xFF242420),
    border: Color(0xFF2E2E2A),
    borderStrong: Color(0xFF3A3A35),
    ink: Color(0xFFF2F2EC),
    inkSecondary: Color(0xFFB4B4AA),
    inkMuted: Color(0xFF8C8C82),
    inkOnPrimary: Color(0xFF1C1B16),
    sectorEvents: Color(0xFF9D7BF0),
    sectorEventsContainer: Color(0xFF2B1B4D),
    sectorBDys: Color(0xFFD97706),
    sectorBDysContainer: Color(0xFF3B2410),
    sectorFlavors: Color(0xFF4ADE80),
    sectorFlavorsContainer: Color(0xFF0F2A1A),
    sectorSnapDys: Color(0xFF60A5FA),
    sectorSnapDysContainer: Color(0xFF12233F),
  );

  /// The palette for [brightness] (used by AppTheme when building either
  /// theme so both ThemeData instances stay consistent).
  static Palette paletteFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkPalette : lightPalette;

  // Brand & Semantic
  static Color get primary => palette.primary;
  static Color get primaryHover => palette.primaryHover;
  static Color get primaryContainer => palette.primaryContainer;
  static Color get primaryContainerInk => palette.primaryContainerInk;
  static Color get success => palette.success;
  static Color get successContainer => palette.successContainer;
  static Color get danger => palette.danger;
  static Color get dangerContainer => palette.dangerContainer;
  static Color get warning => palette.warning;
  static Color get warningContainer => palette.warningContainer;

  // Neutral Surfaces
  static Color get surface => palette.surface;
  static Color get surfaceAlt => palette.surfaceAlt;
  static Color get surfaceSunken => palette.surfaceSunken;
  static Color get border => palette.border;
  static Color get borderStrong => palette.borderStrong;

  // Text
  static Color get ink => palette.ink;
  static Color get inkSecondary => palette.inkSecondary;
  static Color get inkMuted => palette.inkMuted;
  static Color get inkOnPrimary => palette.inkOnPrimary;

  // Sector Signature Colors (accent / background)
  static Color get sectorEvents => palette.sectorEvents;
  static Color get sectorEventsContainer => palette.sectorEventsContainer;
  static Color get sectorBDys => palette.sectorBDys;
  static Color get sectorBDysContainer => palette.sectorBDysContainer;
  static Color get sectorFlavors => palette.sectorFlavors;
  static Color get sectorFlavorsContainer => palette.sectorFlavorsContainer;
  static Color get sectorSnapDys => palette.sectorSnapDys;
  static Color get sectorSnapDysContainer => palette.sectorSnapDysContainer;

  // Chart Series Colors
  static Color get totalSales => primary;
  static Color get totalExpenses => danger;
  static Color get netBalance => success;
}

/// Immutable color token set for one brightness. See [AppColors] for the
/// token semantics; both palettes share the same names/roles.
class Palette {
  const Palette({
    required this.primary,
    required this.primaryHover,
    required this.primaryContainer,
    required this.primaryContainerInk,
    required this.success,
    required this.successContainer,
    required this.danger,
    required this.dangerContainer,
    required this.warning,
    required this.warningContainer,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.inkOnPrimary,
    required this.sectorEvents,
    required this.sectorEventsContainer,
    required this.sectorBDys,
    required this.sectorBDysContainer,
    required this.sectorFlavors,
    required this.sectorFlavorsContainer,
    required this.sectorSnapDys,
    required this.sectorSnapDysContainer,
  });

  final Color primary;
  final Color primaryHover;
  final Color primaryContainer;
  final Color primaryContainerInk;
  final Color success;
  final Color successContainer;
  final Color danger;
  final Color dangerContainer;
  final Color warning;
  final Color warningContainer;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color inkSecondary;
  final Color inkMuted;
  final Color inkOnPrimary;
  final Color sectorEvents;
  final Color sectorEventsContainer;
  final Color sectorBDys;
  final Color sectorBDysContainer;
  final Color sectorFlavors;
  final Color sectorFlavorsContainer;
  final Color sectorSnapDys;
  final Color sectorSnapDysContainer;
}

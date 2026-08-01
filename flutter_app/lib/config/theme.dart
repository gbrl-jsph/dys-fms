import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the UI Style Guide (ui-style-guide.md).
///
/// 14 base color tokens + 5 sector signature colors + typography scale +
/// spacing system + border radius + shadows.
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

/// Typography scale from the UI Style Guide (Section: Typography).
class AppTypography {
  AppTypography._();

  static const double display = 22;
  static const double title = 17;
  static const double body = 14;
  static const double label = 12.5;
  static const double caption = 11;

  static const double letterSpacingSectionLabel = 0.5;
  static const double letterSpacingTableHeader = 0.4;
}

/// Spacing system — 8pt grid (UI Style Guide: Spacing System).
class AppSpacing {
  AppSpacing._();

  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 24;
  static const double sp6 = 32;
  static const double sp7 = 40;
}

/// Border radius tokens (UI Style Guide: Border Radius).
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

/// Elevation / shadow tokens (UI Style Guide: Elevation / Shadows).
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

/// Material 3 ThemeData factory built from the UI Style Guide.
///
/// - `ColorScheme.fromSeed` based on `--primary` (#4338CA)
/// - Inter font family (google_fonts) with the 5-level type scale
/// - Component themes: Card, ElevatedButton, OutlinedButton,
///   InputDecoration, NavigationBar, TextField
class ThemeConfig {
  ThemeConfig._();

  static ThemeData build() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.inkOnPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryContainerInk,
      secondary: AppColors.inkSecondary,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.surfaceSunken,
      onSecondaryContainer: AppColors.ink,
      error: AppColors.danger,
      onError: AppColors.surface,
      errorContainer: AppColors.dangerContainer,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
      scrim: AppColors.ink,
    );

    final TextTheme textTheme = GoogleFonts.interTextTheme().copyWith(
      displaySmall: GoogleFonts.inter(
        fontSize: AppTypography.display,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: AppTypography.title,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppTypography.caption,
        fontWeight: FontWeight.w400,
        color: AppColors.inkSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppTypography.label,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppTypography.caption,
        fontWeight: FontWeight.w700,
        color: AppColors.inkMuted,
        letterSpacing: AppTypography.letterSpacingTableHeader,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.surfaceAlt,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.inkOnPrimary,
          disabledForegroundColor: AppColors.inkMuted,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return AppColors.primaryHover;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary.withValues(alpha: 0.38);
            }
            return AppColors.primary;
          }),
          shadowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.28),
          ),
          elevation: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? 0 : 6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.primaryContainerInk,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.inkMuted,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkMuted,
          side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp3,
          vertical: 11,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: AppTypography.body,
          color: AppColors.inkMuted,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppTypography.label,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSecondary,
        ),
        prefixIconColor: AppColors.inkSecondary,
        suffixIconColor: AppColors.inkSecondary,
        errorStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          color: AppColors.danger,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          color: AppColors.inkMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.inkMuted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

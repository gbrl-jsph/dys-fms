import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Material 3 ThemeData factory built from the UI Style Guide.
///
/// - `ColorScheme.fromSeed` based on `--primary` (#4338CA)
/// - Inter font family (google_fonts) with the 5-level type scale
/// - Component themes: Card, ElevatedButton, OutlinedButton,
///   InputDecoration, NavigationBar, TextField
///
/// [build] resolves every color token against [brightness] so the same
/// component themes serve both light and dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData build(Brightness brightness) {
    final Palette palette = AppColors.paletteFor(brightness);

    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.inkOnPrimary,
          primaryContainer: palette.primaryContainer,
          onPrimaryContainer: palette.primaryContainerInk,
          secondary: palette.inkSecondary,
          onSecondary: palette.surface,
          secondaryContainer: palette.surfaceSunken,
          onSecondaryContainer: palette.ink,
          error: palette.danger,
          onError: palette.surface,
          errorContainer: palette.dangerContainer,
          onErrorContainer: palette.danger,
          surface: palette.surface,
          onSurface: palette.ink,
          onSurfaceVariant: palette.inkSecondary,
          outline: palette.border,
          outlineVariant: palette.borderStrong,
          scrim: palette.ink,
        );

    final TextTheme textTheme = GoogleFonts.interTextTheme().copyWith(
      displaySmall: GoogleFonts.inter(
        fontSize: AppTypography.display,
        fontWeight: FontWeight.w800,
        color: palette.ink,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: AppTypography.title,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppTypography.caption,
        fontWeight: FontWeight.w400,
        color: palette.inkSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppTypography.label,
        fontWeight: FontWeight.w600,
        color: palette.inkSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppTypography.caption,
        fontWeight: FontWeight.w700,
        color: palette.inkMuted,
        letterSpacing: AppTypography.letterSpacingTableHeader,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: palette.surfaceAlt,
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: palette.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              foregroundColor: palette.inkOnPrimary,
              disabledForegroundColor: palette.inkMuted,
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
                  return palette.primaryHover;
                }
                if (states.contains(WidgetState.disabled)) {
                  return palette.primary.withValues(alpha: 0.38);
                }
                return palette.primary;
              }),
              shadowColor: WidgetStateProperty.all(
                palette.primary.withValues(alpha: 0.28),
              ),
              elevation: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled) ? 0 : 6,
              ),
            ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primaryContainer,
          foregroundColor: palette.primaryContainerInk,
          disabledBackgroundColor: palette.primaryContainer.withValues(
            alpha: 0.38,
          ),
          disabledForegroundColor: palette.inkMuted,
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
          backgroundColor: palette.surface,
          foregroundColor: palette.ink,
          disabledForegroundColor: palette.inkMuted,
          side: BorderSide(color: palette.borderStrong, width: 1.5),
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
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp3,
          vertical: 11,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: AppTypography.body,
          color: palette.inkMuted,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppTypography.label,
          fontWeight: FontWeight.w600,
          color: palette.inkSecondary,
        ),
        prefixIconColor: palette.inkSecondary,
        suffixIconColor: palette.inkSecondary,
        errorStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          color: palette.danger,
        ),
        helperStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          color: palette.inkMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primaryContainer,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.inkMuted,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

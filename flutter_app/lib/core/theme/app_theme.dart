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
class AppTheme {
  AppTheme._();

  static ThemeData build() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
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
        style:
            ElevatedButton.styleFrom(
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
          disabledBackgroundColor: AppColors.primaryContainer.withValues(
            alpha: 0.38,
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Material 3 ThemeData factory built from the black + gold branding.
///
/// - `ColorScheme.fromSeed` based on `--primary` (#D4AF37), with every
///   surface role overridden from the palette tokens (no seed-derived
///   surfaces leak through)
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
          surfaceContainerLowest: palette.surface,
          surfaceContainerLow: palette.surface,
          surfaceContainer: palette.surface,
          surfaceContainerHigh: palette.surfaceAlt,
          surfaceContainerHighest: palette.surfaceSunken,
          surfaceDim: palette.surfaceAlt,
          surfaceBright: palette.surface,
          inverseSurface: palette.ink,
          onInverseSurface: palette.surface,
          inversePrimary: palette.primaryHover,
          surfaceTint: Colors.transparent,
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
        indicatorColor: palette.primary,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? palette.inkOnPrimary
                : palette.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? palette.inkOnPrimary
                : palette.inkMuted,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: palette.surfaceAlt,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: palette.border, width: 1),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: palette.border, width: 1),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w500,
          color: palette.ink,
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(palette.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(
            BorderSide(color: palette.border, width: 1),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: palette.primary,
        headerForegroundColor: palette.inkOnPrimary,
        headerHelpStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          color: palette.inkOnPrimary.withValues(alpha: 0.8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: palette.surface,
          hintStyle: GoogleFonts.inter(
            fontSize: AppTypography.body,
            color: palette.inkMuted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: palette.border, width: 1.5),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: GoogleFonts.inter(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
          color: palette.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.ink,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppTypography.caption,
          fontWeight: FontWeight.w600,
          color: palette.surface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surfaceSunken,
        circularTrackColor: palette.surfaceSunken,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(palette.surfaceSunken),
        dataRowColor: const WidgetStatePropertyAll(Colors.transparent),
        dividerThickness: 1,
        headingTextStyle: GoogleFonts.inter(
          fontSize: AppTypography.label,
          fontWeight: FontWeight.w700,
          color: palette.inkMuted,
          letterSpacing: AppTypography.letterSpacingTableHeader,
        ),
        dataTextStyle: GoogleFonts.inter(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w500,
          color: palette.ink,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        side: BorderSide(color: palette.border, width: 1),
        labelStyle: GoogleFonts.inter(
          fontSize: AppTypography.label,
          fontWeight: FontWeight.w600,
          color: palette.inkSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

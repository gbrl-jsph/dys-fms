import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/core/constants/app_colors.dart';
import 'package:dys_fms/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('light theme resolves the style-guide light tokens', (WidgetTester tester) async {
    final ThemeData theme = AppTheme.build(Brightness.light);

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, AppColors.lightPalette.surfaceAlt);
    expect(theme.colorScheme.primary, AppColors.lightPalette.primary);
    expect(theme.colorScheme.onPrimary, AppColors.lightPalette.inkOnPrimary);
    expect(theme.colorScheme.surface, AppColors.lightPalette.surface);
    expect(theme.colorScheme.onSurface, AppColors.lightPalette.ink);
    expect(
      theme.colorScheme.surfaceContainerHighest,
      AppColors.lightPalette.surfaceSunken,
    );
    expect(theme.colorScheme.surfaceContainer, AppColors.lightPalette.surface);
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.colorScheme.inverseSurface, AppColors.lightPalette.ink);
    expect(theme.colorScheme.onInverseSurface, AppColors.lightPalette.surface);

    expect(theme.cardTheme.color, AppColors.lightPalette.surface);
    expect(theme.dialogTheme.backgroundColor, AppColors.lightPalette.surface);
    expect(theme.popupMenuTheme.color, AppColors.lightPalette.surface);
    expect(theme.datePickerTheme.backgroundColor, AppColors.lightPalette.surface);
    expect(
      theme.datePickerTheme.headerBackgroundColor,
      AppColors.lightPalette.primary,
    );
    expect(theme.snackBarTheme.backgroundColor, AppColors.lightPalette.ink);
    expect(theme.snackBarTheme.contentTextStyle?.color, AppColors.lightPalette.surface);
    expect(
      theme.progressIndicatorTheme.linearTrackColor,
      AppColors.lightPalette.surfaceSunken,
    );
    expect(theme.dataTableTheme.headingRowColor?.resolve({}), AppColors.lightPalette.surfaceSunken);
    expect(theme.navigationBarTheme.backgroundColor, AppColors.lightPalette.surface);
    expect(theme.bottomSheetTheme.backgroundColor, AppColors.lightPalette.surface);
  });

  testWidgets('dark theme resolves the approved dark tokens', (WidgetTester tester) async {
    final ThemeData theme = AppTheme.build(Brightness.dark);

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.darkPalette.surfaceAlt);
    expect(theme.colorScheme.primary, AppColors.darkPalette.primary);
    expect(theme.colorScheme.onPrimary, AppColors.darkPalette.inkOnPrimary);
    expect(theme.colorScheme.surface, AppColors.darkPalette.surface);
    expect(theme.colorScheme.onSurface, AppColors.darkPalette.ink);
    expect(
      theme.colorScheme.surfaceContainerHighest,
      AppColors.darkPalette.surfaceSunken,
    );
    expect(theme.colorScheme.surfaceContainer, AppColors.darkPalette.surface);
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.colorScheme.inverseSurface, AppColors.darkPalette.ink);
    expect(theme.colorScheme.onInverseSurface, AppColors.darkPalette.surface);

    expect(theme.cardTheme.color, AppColors.darkPalette.surface);
    expect(theme.dialogTheme.backgroundColor, AppColors.darkPalette.surface);
    expect(theme.popupMenuTheme.color, AppColors.darkPalette.surface);
    expect(theme.datePickerTheme.backgroundColor, AppColors.darkPalette.surface);
    expect(
      theme.datePickerTheme.headerBackgroundColor,
      AppColors.darkPalette.primary,
    );
    expect(theme.snackBarTheme.backgroundColor, AppColors.darkPalette.ink);
    expect(theme.snackBarTheme.contentTextStyle?.color, AppColors.darkPalette.surface);
    expect(
      theme.progressIndicatorTheme.linearTrackColor,
      AppColors.darkPalette.surfaceSunken,
    );
    expect(theme.dataTableTheme.headingRowColor?.resolve({}), AppColors.darkPalette.surfaceSunken);
    expect(theme.navigationBarTheme.backgroundColor, AppColors.darkPalette.surface);
    expect(theme.bottomSheetTheme.backgroundColor, AppColors.darkPalette.surface);
  });

  testWidgets('both themes share the same structure with no seed-derived surfaces', (WidgetTester tester) async {
    for (final Brightness brightness in Brightness.values) {
      final Palette palette = AppColors.paletteFor(brightness);
      final ThemeData theme = AppTheme.build(brightness);

      expect(theme.colorScheme.surface, palette.surface);
      expect(theme.colorScheme.onSurfaceVariant, palette.inkSecondary);
      expect(theme.colorScheme.outline, palette.border);
      expect(theme.colorScheme.error, palette.danger);
      expect(theme.colorScheme.scrim, palette.ink);
      expect(theme.scaffoldBackgroundColor, palette.surfaceAlt);
      expect(theme.textTheme.bodyLarge?.color, palette.ink);
      expect(theme.textTheme.bodySmall?.color, palette.inkSecondary);
      expect(theme.appBarTheme.backgroundColor, palette.surface);
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/constants/app_colors.dart';
import 'package:dys_fms/core/constants/app_info.dart';
import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/core/theme/theme_controller.dart';
import 'package:dys_fms/core/theme/theme_mode_store.dart';
import 'package:dys_fms/features/settings/presentation/screens/settings_screen.dart';

/// In-memory [ThemeModeStore] fake tracking the persisted mode.
class _FakeThemeModeStore implements ThemeModeStore {
  ThemeMode? stored;

  @override
  Future<void> save(ThemeMode mode) async => stored = mode;

  @override
  Future<ThemeMode?> load() async => stored;
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSettings(
    WidgetTester tester,
    ThemeController controller,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeController>.value(
        value: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? child) {
            final Brightness resolved = controller.resolve(
              WidgetsBinding.instance.platformDispatcher.platformBrightness,
            );
            AppColors.setBrightness(resolved);

            return MaterialApp(
              theme: AppTheme.build(Brightness.light),
              darkTheme: AppTheme.build(Brightness.dark),
              themeMode: controller.mode,
              home: const SettingsScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the Appearance and About sections', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, ThemeController(_FakeThemeModeStore()));

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text(AppInfo.appName), findsOneWidget);
    expect(find.text('Version ${AppInfo.appVersion}'), findsOneWidget);
  });

  testWidgets('System Default is selected by default', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, ThemeController(_FakeThemeModeStore()));

    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, 'System Default'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the persisted mode is restored and selected', (
    WidgetTester tester,
  ) async {
    final _FakeThemeModeStore store = _FakeThemeModeStore()
      ..stored = ThemeMode.dark;
    final ThemeController controller = ThemeController(store);
    await controller.initialize();

    await pumpSettings(tester, controller);

    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, 'Dark'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping Dark switches the app to dark mode and persists', (
    WidgetTester tester,
  ) async {
    final _FakeThemeModeStore store = _FakeThemeModeStore();
    final ThemeController controller = ThemeController(store);

    await pumpSettings(tester, controller);
    await tester.tap(find.widgetWithText(InkWell, 'Dark'));
    await tester.pumpAndSettle();

    expect(controller.mode, ThemeMode.dark);
    expect(store.stored, ThemeMode.dark);
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, 'Dark'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    final BuildContext context = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppColors.darkPalette.surfaceAlt,
    );
  });

  testWidgets('tapping Light switches back to light mode', (
    WidgetTester tester,
  ) async {
    final ThemeController controller = ThemeController(
      _FakeThemeModeStore(),
      initialMode: ThemeMode.dark,
    );

    await pumpSettings(tester, controller);
    await tester.tap(find.widgetWithText(InkWell, 'Light'));
    await tester.pumpAndSettle();

    expect(controller.mode, ThemeMode.light);
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, 'Light'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets('System Default follows the device brightness', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final ThemeController controller = ThemeController(
      _FakeThemeModeStore(),
      initialMode: ThemeMode.system,
    );

    await pumpSettings(tester, controller);

    final BuildContext context = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppColors.darkPalette.surfaceAlt,
    );
  });
}

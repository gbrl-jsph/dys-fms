import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/theme/theme_controller.dart';
import 'package:dys_fms/core/theme/theme_mode_store.dart';

/// In-memory [ThemeModeStore] fake with optional storage failures.
class _FakeThemeModeStore implements ThemeModeStore {
  ThemeMode? stored;
  bool failLoad = false;
  bool failSave = false;

  @override
  Future<void> save(ThemeMode mode) async {
    if (failSave) throw Exception('storage unavailable');
    stored = mode;
  }

  @override
  Future<ThemeMode?> load() async {
    if (failLoad) throw Exception('storage unavailable');
    return stored;
  }
}

void main() {
  test('initialize() restores the persisted mode and notifies once', () async {
    final _FakeThemeModeStore store = _FakeThemeModeStore()
      ..stored = ThemeMode.dark;
    final ThemeController controller = ThemeController(store);
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.initialize();

    expect(controller.mode, ThemeMode.dark);
    expect(notifications, 1);
  });

  test('initialize() keeps the initial mode when nothing is stored', () async {
    final ThemeController controller = ThemeController(
      _FakeThemeModeStore(),
      initialMode: ThemeMode.light,
    );
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.initialize();

    expect(controller.mode, ThemeMode.light);
    expect(notifications, 0);
  });

  test('setMode() switches the mode and persists it', () async {
    final _FakeThemeModeStore store = _FakeThemeModeStore();
    final ThemeController controller = ThemeController(store);
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setMode(ThemeMode.dark);

    expect(controller.mode, ThemeMode.dark);
    expect(store.stored, ThemeMode.dark);
    expect(notifications, 1);
  });

  test('setMode() ignores the currently selected mode', () async {
    final _FakeThemeModeStore store = _FakeThemeModeStore();
    final ThemeController controller = ThemeController(
      store,
      initialMode: ThemeMode.light,
    );
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setMode(ThemeMode.light);

    expect(controller.mode, ThemeMode.light);
    expect(store.stored, isNull);
    expect(notifications, 0);
  });

  test('resolve() maps each mode to the expected brightness', () {
    final ThemeController controller = ThemeController(
      _FakeThemeModeStore(),
      initialMode: ThemeMode.light,
    );

    expect(controller.resolve(Brightness.dark), Brightness.light);

    controller.setMode(ThemeMode.dark);
    expect(controller.resolve(Brightness.light), Brightness.dark);

    controller.setMode(ThemeMode.system);
    expect(controller.resolve(Brightness.light), Brightness.light);
    expect(controller.resolve(Brightness.dark), Brightness.dark);
  });

  test('initialize() falls back to the initial mode on storage failure', () async {
    final _FakeThemeModeStore store = _FakeThemeModeStore()..failLoad = true;
    final ThemeController controller = ThemeController(store);
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.initialize();

    expect(controller.mode, ThemeMode.system);
    expect(notifications, 0);
  });

  test('setMode() still applies in-session when persistence fails', () async {
    final _FakeThemeModeStore store = _FakeThemeModeStore()..failSave = true;
    final ThemeController controller = ThemeController(store);

    await controller.setMode(ThemeMode.dark);

    expect(controller.mode, ThemeMode.dark);
  });
}

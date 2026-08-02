import 'package:flutter/material.dart';

import 'theme_mode_store.dart';

/// App-wide theme mode controller (Material 3, Light / Dark / System).
///
/// Owns the selected [ThemeMode], persists it through [ThemeModeStore],
/// and resolves the effective [Brightness] against the platform
/// brightness when the mode is `system`. The root widget listens to this
/// controller so the whole app rebuilds on change without duplicating
/// theme code per screen.
class ThemeController extends ChangeNotifier {
  ThemeController(
    this._store, {
    ThemeMode initialMode = ThemeMode.system,
  }) : _mode = initialMode;

  final ThemeModeStore _store;

  ThemeMode _mode;

  /// The selected theme mode.
  ThemeMode get mode => _mode;

  /// Restores the persisted mode (called once at startup before the app
  /// renders, so there is no theme flash). Storage failures fall back to
  /// the initial mode.
  Future<void> initialize() async {
    try {
      final ThemeMode? stored = await _store.load();
      if (stored != null && stored != _mode) {
        _mode = stored;
        notifyListeners();
      }
    } catch (_) {
      // Persistence unavailable — keep the default mode.
    }
  }

  /// Selects a new [mode] and persists it. Persistence failures do not
  /// block the in-session switch.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await _store.save(mode);
    } catch (_) {
      // Persistence unavailable — the in-session switch still applies.
    }
  }

  /// The brightness the app should render with for [platformBrightness].
  Brightness resolve(Brightness platformBrightness) {
    switch (_mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return platformBrightness;
    }
  }

  /// Invoked by the app root when the OS brightness changes so widgets
  /// rebuild in `system` mode.
  void handlePlatformBrightnessChanged() => notifyListeners();
}

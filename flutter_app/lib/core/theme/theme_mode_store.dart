import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the app-wide theme mode (light / dark / system) in secure
/// storage so the preference survives restarts without touching
/// SharedPreferences (AES-GCM encrypted, same options as auth storage).
class ThemeModeStore {
  ThemeModeStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
            ),
          );

  static const String _themeModeKey = 'theme_mode';

  final FlutterSecureStorage _storage;

  /// Stores the selected [ThemeMode] under the `theme_mode` key.
  Future<void> save(ThemeMode mode) =>
      _storage.write(key: _themeModeKey, value: mode.name);

  /// Retrieves the stored mode, returning `null` when absent or unknown.
  Future<ThemeMode?> load() async {
    final String? raw = await _storage.read(key: _themeModeKey);
    if (raw == null) return null;

    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }

    return null;
  }
}

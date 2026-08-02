import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence wrapper for auth data.
///
/// Per blueprint §4.3: AES-GCM encryption on Android (Android Keystore)
/// and Keychain on iOS. The token is never stored in plaintext or
/// SharedPreferences.
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
            ),
          );

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  final FlutterSecureStorage _storage;

  /// Stores the `auth_token` key.
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// Retrieves `auth_token`, returning `null` when absent.
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Removes `auth_token`.
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  /// Stores a JSON string of user info (role, sector_id, etc.).
  Future<void> saveUserData(Map<String, dynamic> userData) =>
      _storage.write(key: _userDataKey, value: jsonEncode(userData));

  /// Retrieves and deserializes user data, returning `null` when absent.
  Future<Map<String, dynamic>?> getUserData() async {
    final String? raw = await _storage.read(key: _userDataKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Clears all stored data (used on logout).
  Future<void> deleteAll() => _storage.deleteAll();

  /// Checks if a token exists and is non-empty.
  Future<bool> isLoggedIn() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

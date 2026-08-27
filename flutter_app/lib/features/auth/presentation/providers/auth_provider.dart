import 'package:flutter/foundation.dart';

import '../../../../data/api/api_error_mapper.dart';
import '../../data/models/login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth_state.dart';

/// Authentication state management (blueprint §4.7).
///
/// Delegates all data access to [AuthRepository]; exposes only the
/// state and methods required by the blueprint.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthState _state = const AuthState();

  AuthState get state => _state;

  Future<void> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final result = await _authRepository.login(email, password);
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        token: result.token,
        defaultSector: result.defaultSector,
      );
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      _state = const AuthState();
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final bool authenticated = await _authRepository.isAuthenticated();
    if (authenticated) {
      final user = await _authRepository.getStoredUser();
      _state = _state.copyWith(isAuthenticated: true, user: user);
    } else {
      _state = _state.copyWith(isAuthenticated: false);
    }
    notifyListeners();
  }

  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(error: null);
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final updated = await _authRepository.updateProfile(name);
      _state = _state.copyWith(isLoading: false, user: updated);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _state = const AuthState();
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      _state = _state.copyWith(isLoading: false);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _authRepository.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _state = _state.copyWith(isLoading: false);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  /// Updates the client-side sector context after a successful sector
  /// switch (FR-008).
  ///
  /// The switch endpoint is stateless, so no backend call is made;
  /// all screens scoped by [AuthState.defaultSector] pick up the new
  /// sector on the next notification.
  void updateSector(DefaultSector sector) {
    _state = _state.copyWith(defaultSector: sector);
    notifyListeners();
  }
}

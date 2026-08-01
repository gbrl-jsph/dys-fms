import 'package:flutter/foundation.dart';

import '../../../../core/network/api_error_mapper.dart';
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
}

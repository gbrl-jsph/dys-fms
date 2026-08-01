import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      _state = _state.copyWith(isLoading: false, error: _errorMessage(error));
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

  /// Maps exceptions to a user-friendly error message (blueprint §4.4).
  String _errorMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Unable to connect to the server. Please try again.';
      }

      final response = error.response;
      if (response != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
          final errors = data['errors'];
          if (errors is Map<String, dynamic> && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty && first.first is String) {
              return first.first as String;
            }
          }
        }
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

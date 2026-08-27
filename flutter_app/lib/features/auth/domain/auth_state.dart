import '../data/models/login_response.dart';
import '../data/models/user_model.dart';

/// Immutable authentication state managed by [AuthProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.defaultSector,
    this.error,
  });

  /// Tracks login/logout in progress.
  final bool isLoading;

  /// Derived from token presence.
  final bool isAuthenticated;

  /// Authenticated user data.
  final UserModel? user;

  /// Sanctum token issued at login.
  final String? token;

  /// Initial sector context returned at login.
  final DefaultSector? defaultSector;

  /// Error message to display.
  final String? error;

  static const Object _sentinel = Object();

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? token,
    DefaultSector? defaultSector,
    Object? error = _sentinel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      defaultSector: defaultSector ?? this.defaultSector,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

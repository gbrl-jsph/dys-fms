import '../data/models/user_account.dart';

/// Immutable user management state managed by [UsersProvider].
///
/// Updated via [copyWith] so every published state is consistent.
class UsersState {
  const UsersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.users = const [],
    this.error,
    this.successMessage,
    this.lastTemporaryPassword,
  });

  /// Tracks the user list fetch in progress.
  final bool isLoading;

  /// Tracks create/update/status submission in progress.
  final bool isSubmitting;

  /// All user accounts from GET /users.
  final List<UserAccount> users;

  /// Error message to display.
  final String? error;

  /// Success feedback message to display.
  final String? successMessage;

  /// One-time temporary password returned by POST /users.
  final String? lastTemporaryPassword;

  /// Sentinel distinguishing "not provided" from an explicit null in
  /// [copyWith], so nullable fields can be cleared by passing null.
  static const Object _unset = Object();

  UsersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<UserAccount>? users,
    Object? error = _unset,
    Object? successMessage = _unset,
    Object? lastTemporaryPassword = _unset,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      users: users ?? this.users,
      error: identical(error, _unset) ? this.error : error as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      lastTemporaryPassword: identical(lastTemporaryPassword, _unset)
          ? this.lastTemporaryPassword
          : lastTemporaryPassword as String?,
    );
  }
}

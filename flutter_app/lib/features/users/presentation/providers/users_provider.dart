import 'package:flutter/foundation.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../data/models/save_user_request.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/users_repository.dart';
import '../../domain/users_state.dart';

/// User management state (Phase 2, FR-003).
///
/// Delegates all data access to [UsersRepository]; exposes only the
/// state and methods required by the User Account Management screen.
class UsersProvider extends ChangeNotifier {
  UsersProvider(this._usersRepository);

  final UsersRepository _usersRepository;

  UsersState _state = const UsersState();

  UsersState get state => _state;

  /// GET /api/users — load the full user list.
  Future<void> loadUsers() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final List<UserAccount> users = await _usersRepository.getUsers();
      _state = _state.copyWith(isLoading: false, users: users);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// POST /api/users — create an account; surfaces the one-time temporary
  /// password returned by the backend and refreshes the list.
  Future<void> createUser(SaveUserRequest request) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
      lastTemporaryPassword: null,
    );
    notifyListeners();

    try {
      final account = await _usersRepository.createUser(request);
      final users = await _usersRepository.getUsers();
      _state = _state.copyWith(
        isSubmitting: false,
        users: users,
        successMessage: 'User account created successfully.',
        lastTemporaryPassword: account.temporaryPassword,
      );
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// PUT /api/users/{id} — update name, email, role, and sector.
  Future<void> updateUser(int id, SaveUserRequest request) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _usersRepository.updateUser(id, request);
      final users = await _usersRepository.getUsers();
      _state = _state.copyWith(
        isSubmitting: false,
        users: users,
        successMessage: 'User updated successfully.',
      );
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  /// PATCH /api/users/{id}/status — activate or deactivate an account.
  Future<void> updateUserStatus(int id, String accountStatus) async {
    _state = _state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _usersRepository.updateUserStatus(id, accountStatus);
      final users = await _usersRepository.getUsers();
      _state = _state.copyWith(
        isSubmitting: false,
        users: users,
        successMessage: 'User status updated successfully.',
      );
    } catch (error) {
      _state = _state.copyWith(isSubmitting: false, error: apiErrorMessage(error));
    }

    notifyListeners();
  }

  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(error: null);
      notifyListeners();
    }
  }

  void clearSuccess() {
    if (_state.successMessage != null || _state.lastTemporaryPassword != null) {
      _state = _state.copyWith(
        successMessage: null,
        lastTemporaryPassword: null,
      );
      notifyListeners();
    }
  }
}

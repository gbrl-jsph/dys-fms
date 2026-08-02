import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../storage/secure_storage.dart';

/// Auth data operations: login, logout, and local session inspection.
///
/// All HTTP calls go through the shared [dio] client; the token is
/// attached automatically by the auth interceptor. All persistence goes
/// through [SecureStorage]. No business logic lives outside this
/// repository.
class AuthRepository extends Repository {
  AuthRepository(super.apiClient, this._secureStorage);

  final SecureStorage _secureStorage;

  /// POST /api/login — authenticate and persist the session.
  Future<LoginResponse> login(String email, String password) async {
    final response = await dio.post<dynamic>(
      ApiConfig.loginEndpoint,
      data: LoginRequest(email: email, password: password).toJson(),
    );

    final LoginResponse loginResponse = LoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    await _secureStorage.saveToken(loginResponse.token);
    await _secureStorage.saveUserData({
      'id': loginResponse.user.id,
      'name': loginResponse.user.name,
      'email': loginResponse.user.email,
      'role': loginResponse.user.role,
      'sector_id': loginResponse.user.sectorId,
      'account_status': loginResponse.user.accountStatus,
    });

    return loginResponse;
  }

  /// POST /api/logout — revoke the token (auto-attached by the
  /// interceptor) and clear all locally stored session data.
  Future<void> logout() async {
    await dio.post<void>(ApiConfig.logoutEndpoint);
    await _secureStorage.deleteAll();
  }

  /// Returns whether a non-empty token is stored locally.
  Future<bool> isAuthenticated() => _secureStorage.isLoggedIn();

  /// Returns the locally stored user, or `null` when absent.
  Future<UserModel?> getStoredUser() async {
    final Map<String, dynamic>? userData = await _secureStorage.getUserData();
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }
}

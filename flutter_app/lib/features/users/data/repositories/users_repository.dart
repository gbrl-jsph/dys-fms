import '../../../../data/api/api_config.dart';
import '../../../../data/repositories/repository_base.dart';
import '../models/save_user_request.dart';
import '../models/update_user_status_request.dart';
import '../models/user_account.dart';

/// User management data operations (Phase 2, FR-003).
///
/// All HTTP calls go through the shared [dio] client; the bearer token
/// is attached automatically by the auth interceptor. No business logic
/// lives here.
class UsersRepository extends Repository {
  UsersRepository(super.apiClient);

  /// GET /api/users — list all users with denormalized sector names.
  Future<List<UserAccount>> getUsers() async {
    final dynamic response = await dio.get<dynamic>(ApiConfig.usersEndpoint);
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> list = body['data'] as List<dynamic>;

    return list
        .map(
          (dynamic item) => UserAccount.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// GET /api/users/{id} — retrieve a single user account.
  Future<UserAccount> getUser(int id) async {
    final dynamic response = await dio.get<dynamic>(ApiConfig.userEndpoint(id));
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return UserAccount.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /api/users — create an account. The response contains the
  /// one-time temporary password (`temporary_password`).
  Future<UserAccount> createUser(SaveUserRequest request) async {
    final dynamic response = await dio.post<dynamic>(
      ApiConfig.usersEndpoint,
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return UserAccount.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// PUT /api/users/{id} — update name, email, role, and sector assignment.
  Future<UserAccount> updateUser(int id, SaveUserRequest request) async {
    final dynamic response = await dio.put<dynamic>(
      ApiConfig.userEndpoint(id),
      data: request.toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return UserAccount.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// PATCH /api/users/{id}/status — activate or deactivate an account.
  Future<UserAccount> updateUserStatus(int id, String accountStatus) async {
    final dynamic response = await dio.patch<dynamic>(
      ApiConfig.userStatusEndpoint(id),
      data: UpdateUserStatusRequest(accountStatus: accountStatus).toJson(),
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;

    return UserAccount.fromJson(body['data'] as Map<String, dynamic>);
  }
}

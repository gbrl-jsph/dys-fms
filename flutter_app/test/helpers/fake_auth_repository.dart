import 'package:dio/dio.dart';

import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/data/repositories/auth_repository.dart';

/// Sample owner payload matching the API spec `data.user`.
const Map<String, dynamic> ownerUserJson = {
  'id': 1,
  'name': 'Juan Dela Cruz',
  'email': 'owner@dys.com',
  'role': 'Business Owner',
  'sector_id': null,
  'account_status': 'Active',
};

/// Sample successful login response per the API spec.
LoginResponse buildLoginResponse() => LoginResponse.fromJson({
  'data': {
    'user': ownerUserJson,
    'token': '1|test-token',
    'default_sector': {'id': 1, 'name': 'DYS Events'},
  },
  'message': 'Login successful.',
});

/// 401 DioException matching the backend's error message.
DioException buildUnauthorizedException() {
  final RequestOptions options = RequestOptions(path: '/api/login');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'Invalid username or password.'},
    ),
  );
}

/// In-memory [AuthRepository] fake with overridable callbacks.
class FakeAuthRepository implements AuthRepository {
  Future<LoginResponse> Function(String email, String password)? onLogin;
  Future<void> Function()? onLogout;
  Future<bool> Function()? onIsAuthenticated;
  Future<UserModel?> Function()? onGetStoredUser;
  Future<UserModel> Function(String name)? onUpdateProfile;
  Future<void> Function(String currentPassword, String newPassword, String newPasswordConfirmation)? onChangePassword;
  Future<void> Function(String email)? onForgotPassword;
  Future<void> Function(String email, String token, String password, String passwordConfirmation)? onResetPassword;

  @override
  late final Dio dio = Dio();

  @override
  Future<LoginResponse> login(String email, String password) =>
      onLogin!(email, password);

  @override
  Future<void> logout() => onLogout!();

  @override
  Future<bool> isAuthenticated() => onIsAuthenticated!();

  @override
  Future<UserModel?> getStoredUser() => onGetStoredUser!();

  @override
  Future<UserModel> updateProfile(String name) =>
      onUpdateProfile != null ? onUpdateProfile!(name) : throw UnimplementedError();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) =>
      onChangePassword != null
          ? onChangePassword!(currentPassword, newPassword, newPasswordConfirmation)
          : throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) =>
      onForgotPassword != null ? onForgotPassword!(email) : throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) =>
      onResetPassword != null
          ? onResetPassword!(email, token, password, passwordConfirmation)
          : throw UnimplementedError();
}

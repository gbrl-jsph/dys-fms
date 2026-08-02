import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/data/repositories/auth_repository.dart';
import 'package:dys_fms/features/auth/data/storage/secure_storage.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_http_adapter.dart';

/// Successful `POST /api/login` response body per the API spec.
const Map<String, dynamic> loginResponseBody = {
  'data': {
    'user': ownerUserJson,
    'token': '1|test-token',
    'default_sector': {'id': 1, 'name': 'DYS Events'},
  },
  'message': 'Login successful.',
};

/// In-memory [SecureStorage] fake tracking writes and deletes.
class FakeSecureStorage extends SecureStorage {
  String? token;
  Map<String, dynamic>? userData;
  bool deleteAllCalled = false;

  @override
  Future<void> saveToken(String value) async => token = value;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<void> saveUserData(Map<String, dynamic> value) async =>
      userData = value;

  @override
  Future<Map<String, dynamic>?> getUserData() async => userData;

  @override
  Future<void> deleteAll() async {
    deleteAllCalled = true;
    token = null;
    userData = null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final String? value = token;
    return value != null && value.isNotEmpty;
  }
}

void main() {
  late FakeHttpClientAdapter adapter;
  late FakeSecureStorage storage;
  late AuthRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    storage = FakeSecureStorage();
    ApiClient.init(tokenProvider: storage.getToken, httpClientAdapter: adapter);
    repository = AuthRepository(ApiClient.instance, storage);
  });

  test('login() posts to /api/login and persists the token and user', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, loginResponseBody);
    };

    final LoginResponse response = await repository.login(
      'owner@dys.com',
      'SecurePass123',
    );

    expect(captured?.path, '/login');
    expect(captured?.method, 'POST');
    expect(captured?.data, {
      'email': 'owner@dys.com',
      'password': 'SecurePass123',
    });

    expect(response.token, '1|test-token');
    expect(response.user.name, 'Juan Dela Cruz');
    expect(response.user.role, 'Business Owner');
    expect(response.defaultSector?.name, 'DYS Events');

    expect(storage.token, '1|test-token');
    expect(storage.userData?['email'], 'owner@dys.com');
    expect(storage.userData?['role'], 'Business Owner');
    expect(storage.userData?['sector_id'], isNull);
  });

  test('login() propagates the DioException for invalid credentials', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(401, {'message': 'Invalid username or password.'});

    await expectLater(
      repository.login('owner@dys.com', 'wrong'),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map<String, dynamic>)['message'],
          'message',
          'Invalid username or password.',
        ),
      ),
    );

    expect(storage.token, isNull);
    expect(storage.userData, isNull);
  });

  test(
    'logout() posts to /api/logout with the bearer token and clears data',
    () async {
      storage.token = '1|stored-token';
      storage.userData = {'email': 'owner@dys.com'};
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, <String, dynamic>{});
      };

      await repository.logout();

      expect(captured?.path, '/logout');
      expect(captured?.method, 'POST');
      expect(captured?.headers['Authorization'], 'Bearer 1|stored-token');
      expect(storage.deleteAllCalled, isTrue);
      expect(storage.token, isNull);
      expect(storage.userData, isNull);
    },
  );

  test('isAuthenticated() reflects the stored token', () async {
    expect(await repository.isAuthenticated(), isFalse);

    storage.token = 'abc';
    expect(await repository.isAuthenticated(), isTrue);
  });

  test('getStoredUser() restores the stored user', () async {
    expect(await repository.getStoredUser(), isNull);

    storage.userData = Map<String, dynamic>.from(ownerUserJson);
    final UserModel? user = await repository.getStoredUser();

    expect(user?.id, 1);
    expect(user?.name, 'Juan Dela Cruz');
    expect(user?.email, 'owner@dys.com');
    expect(user?.role, 'Business Owner');
    expect(user?.accountStatus, 'Active');
  });
}

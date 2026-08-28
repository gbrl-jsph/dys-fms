import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/users/data/models/save_user_request.dart';
import 'package:dys_fms/features/users/data/models/user_account.dart';
import 'package:dys_fms/features/users/data/repositories/users_repository.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_users_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late UsersRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, tokenClearer: () async {}, httpClientAdapter: adapter);
    repository = UsersRepository(ApiClient.instance);
  });

  test('getUsers() GETs /users and parses the account list', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': [mariaUserJson, pedroUserJson],
        'message': 'Users retrieved successfully.',
      });
    };

    final List<UserAccount> users = await repository.getUsers();

    expect(captured?.path, '/users');
    expect(captured?.method, 'GET');
    expect(users, hasLength(2));
    expect(users.first.name, 'Maria Santos');
    expect(users.first.email, 'maria@dys.com');
    expect(users.first.role, 'Event Manager');
    expect(users.first.sectorId, 2);
    expect(users.first.sectorName, 'B&DYS');
    expect(users.first.accountStatus, 'Active');
    expect(users.first.isActive, isTrue);
    expect(users.last.isActive, isFalse);
  });

  test('getUser() GETs /users/{id} and parses a single account', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': mariaUserJson,
        'message': 'User retrieved successfully.',
      });
    };

    final UserAccount user = await repository.getUser(2);

    expect(captured?.path, '/users/2');
    expect(captured?.method, 'GET');
    expect(user.id, 2);
    expect(user.name, 'Maria Santos');
  });

  test('createUser() POSTs /users with the payload and parses '
      'temporary_password', () async {
    RequestOptions? captured;
    final Map<String, dynamic> createdJson = {
      ...mariaUserJson,
      'temporary_password': 'Temp@12345',
    };
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': createdJson,
        'message': 'User created successfully.',
      });
    };

    final UserAccount user = await repository.createUser(
      const SaveUserRequest(
        name: 'Maria Santos',
        email: 'maria@dys.com',
        role: 'Event Manager',
        sectorId: 2,
      ),
    );

    expect(captured?.path, '/users');
    expect(captured?.method, 'POST');
    expect(captured?.data, {
      'name': 'Maria Santos',
      'email': 'maria@dys.com',
      'role': 'Event Manager',
      'sector_id': 2,
    });
    expect(user.temporaryPassword, 'Temp@12345');
  });

  test('updateUser() PUTs /users/{id} with the payload', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': mariaUserJson,
        'message': 'User updated successfully.',
      });
    };

    final UserAccount user = await repository.updateUser(
      2,
      const SaveUserRequest(
        name: 'Maria Santos Updated',
        email: 'maria@dys.com',
        role: 'Event Manager',
        sectorId: 2,
      ),
    );

    expect(captured?.path, '/users/2');
    expect(captured?.method, 'PUT');
    expect(captured?.data, {
      'name': 'Maria Santos Updated',
      'email': 'maria@dys.com',
      'role': 'Event Manager',
      'sector_id': 2,
    });
    expect(user.name, 'Maria Santos');
  });

  test(
    'updateUserStatus() PATCHes /users/{id}/status with account_status',
    () async {
      RequestOptions? captured;
      final Map<String, dynamic> updatedJson = {
        ...mariaUserJson,
        'account_status': 'Inactive',
      };
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': updatedJson,
          'message': 'User status updated successfully.',
        });
      };

      final UserAccount user = await repository.updateUserStatus(2, 'Inactive');

      expect(captured?.path, '/users/2/status');
      expect(captured?.method, 'PATCH');
      expect(captured?.data, {'account_status': 'Inactive'});
      expect(user.accountStatus, 'Inactive');
    },
  );

  test('propagates the DioException for non-owner access (403)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getUsers(),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map<String, dynamic>)['message'],
          'message',
          'Forbidden.',
        ),
      ),
    );
  });
}

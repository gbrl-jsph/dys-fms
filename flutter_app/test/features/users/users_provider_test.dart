import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/features/users/data/models/save_user_request.dart';
import 'package:dys_fms/features/users/data/models/user_account.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';

import '../../helpers/fake_users_repository.dart';

void main() {
  late FakeUsersRepository fakeRepository;
  late UsersProvider provider;

  setUp(() {
    fakeRepository = FakeUsersRepository();
    provider = UsersProvider(fakeRepository);
  });

  DioException buildBadResponseException(
    int statusCode,
    Map<String, dynamic> data,
  ) {
    final RequestOptions options = RequestOptions(path: '/api/users');
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  test('loadUsers populates the user list on success', () async {
    fakeRepository.onGetUsers = () async => buildUsersList();

    await provider.loadUsers();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.error, isNull);
    expect(provider.state.users, hasLength(3));
    expect(provider.state.users.first.name, 'Juan Dela Cruz');
    expect(provider.state.users.last.isActive, isFalse);
  });

  test('loadUsers sets an error message on failure', () async {
    fakeRepository.onGetUsers = () async {
      throw buildBadResponseException(403, {'message': 'Forbidden.'});
    };

    await provider.loadUsers();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.users, isEmpty);
    expect(provider.state.error, 'Forbidden.');
  });

  test(
    'createUser surfaces the temporary password and refreshes the list',
    () async {
      fakeRepository.onCreateUser = (request) async => UserAccount(
        id: 4,
        name: request.name,
        email: request.email,
        role: request.role,
        sectorId: request.sectorId,
        sectorName: 'B&DYS',
        accountStatus: 'Active',
        temporaryPassword: 'Temp@12345',
      );
      fakeRepository.onGetUsers = () async => buildUsersList();

      await provider.createUser(
        const SaveUserRequest(
          name: 'Rosa Martinez',
          email: 'rosa@dys.com',
          role: 'Event Manager',
          sectorId: 2,
        ),
      );

      expect(provider.state.isSubmitting, isFalse);
      expect(provider.state.error, isNull);
      expect(
        provider.state.successMessage,
        'User account created successfully.',
      );
      expect(provider.state.lastTemporaryPassword, 'Temp@12345');
      expect(provider.state.users, hasLength(3));
    },
  );

  test('createUser sets an error message on failure', () async {
    fakeRepository.onCreateUser = (_) async {
      throw buildBadResponseException(422, {
        'message': 'Email has already been taken.',
        'errors': {
          'email': ['Email has already been taken.'],
        },
      });
    };

    await provider.createUser(
      const SaveUserRequest(
        name: 'Rosa Martinez',
        email: 'maria@dys.com',
        role: 'Event Manager',
        sectorId: 2,
      ),
    );

    expect(provider.state.isSubmitting, isFalse);
    expect(provider.state.successMessage, isNull);
    expect(provider.state.error, 'Email has already been taken.');
  });

  test('updateUser sets a success message and refreshes the list', () async {
    fakeRepository.onUpdateUser = (id, request) async => UserAccount(
      id: id,
      name: request.name,
      email: request.email,
      role: request.role,
      sectorId: request.sectorId,
      sectorName: 'B&DYS',
      accountStatus: 'Active',
    );
    fakeRepository.onGetUsers = () async => buildUsersList();

    await provider.updateUser(
      2,
      const SaveUserRequest(
        name: 'Maria Santos Updated',
        email: 'maria.updated@dys.com',
        role: 'Employee/Staff',
        sectorId: 1,
      ),
    );

    expect(provider.state.isSubmitting, isFalse);
    expect(provider.state.successMessage, 'User updated successfully.');
    expect(provider.state.error, isNull);
  });

  test(
    'updateUserStatus sets a success message and refreshes the list',
    () async {
      String? updatedStatus;
      fakeRepository.onUpdateUserStatus = (id, accountStatus) async {
        updatedStatus = accountStatus;
        return UserAccount(
          id: id,
          name: 'Maria Santos',
          email: 'maria@dys.com',
          role: 'Event Manager',
          sectorId: 2,
          sectorName: 'B&DYS',
          accountStatus: accountStatus,
        );
      };
      fakeRepository.onGetUsers = () async => buildUsersList();

      await provider.updateUserStatus(2, 'Inactive');

      expect(updatedStatus, 'Inactive');
      expect(
        provider.state.successMessage,
        'User status updated successfully.',
      );
      expect(provider.state.error, isNull);
    },
  );

  test('updateUserStatus failure surfaces the backend message', () async {
    fakeRepository.onUpdateUserStatus = (_, _) async {
      throw buildBadResponseException(403, {'message': 'Forbidden.'});
    };

    await provider.updateUserStatus(1, 'Inactive');

    expect(provider.state.error, 'Forbidden.');
    expect(provider.state.successMessage, isNull);
    expect(provider.state.isSubmitting, isFalse);
  });

  test(
    'clearSuccess clears the success message and temporary password',
    () async {
      fakeRepository.onCreateUser = (request) async => UserAccount(
        id: 4,
        name: request.name,
        email: request.email,
        role: request.role,
        sectorId: request.sectorId,
        sectorName: 'B&DYS',
        accountStatus: 'Active',
        temporaryPassword: 'Temp@12345',
      );
      fakeRepository.onGetUsers = () async => buildUsersList();

      await provider.createUser(
        const SaveUserRequest(
          name: 'Rosa Martinez',
          email: 'rosa@dys.com',
          role: 'Event Manager',
          sectorId: 2,
        ),
      );
      provider.clearSuccess();

      expect(provider.state.successMessage, isNull);
      expect(provider.state.lastTemporaryPassword, isNull);
    },
  );
}

import 'package:dio/dio.dart';

import 'package:dys_fms/features/users/data/models/save_user_request.dart';
import 'package:dys_fms/features/users/data/models/user_account.dart';
import 'package:dys_fms/features/users/data/repositories/users_repository.dart';

/// Sample user list payloads matching the API spec `data` array.
const Map<String, dynamic> mariaUserJson = {
  'id': 2,
  'name': 'Maria Santos',
  'email': 'maria@dys.com',
  'role': 'Event Manager',
  'sector_id': 2,
  'sector_name': 'B&DYS',
  'account_status': 'Active',
  'created_at': '2026-07-28T11:00:00.000000Z',
};

const Map<String, dynamic> pedroUserJson = {
  'id': 3,
  'name': 'Pedro Reyes',
  'email': 'pedro@dys.com',
  'role': 'Employee/Staff',
  'sector_id': 1,
  'sector_name': 'DYS Events',
  'account_status': 'Inactive',
  'created_at': '2026-07-28T12:00:00.000000Z',
};

List<UserAccount> buildUsersList() => const [
  UserAccount(
    id: 1,
    name: 'Juan Dela Cruz',
    email: 'owner@dys.com',
    role: 'Business Owner',
    sectorId: null,
    sectorName: null,
    accountStatus: 'Active',
  ),
  UserAccount(
    id: 2,
    name: 'Maria Santos',
    email: 'maria@dys.com',
    role: 'Event Manager',
    sectorId: 2,
    sectorName: 'B&DYS',
    accountStatus: 'Active',
  ),
  UserAccount(
    id: 3,
    name: 'Pedro Reyes',
    email: 'pedro@dys.com',
    role: 'Employee/Staff',
    sectorId: 1,
    sectorName: 'DYS Events',
    accountStatus: 'Inactive',
  ),
];

/// In-memory [UsersRepository] fake with overridable callbacks.
class FakeUsersRepository implements UsersRepository {
  Future<List<UserAccount>> Function()? onGetUsers;
  Future<UserAccount> Function(int id)? onGetUser;
  Future<UserAccount> Function(SaveUserRequest request)? onCreateUser;
  Future<UserAccount> Function(int id, SaveUserRequest request)? onUpdateUser;
  Future<UserAccount> Function(int id, String accountStatus)?
  onUpdateUserStatus;
  Future<UserAccount> Function(int id)? onResetPassword;

  @override
  late final Dio dio = Dio();

  @override
  Future<List<UserAccount>> getUsers() => onGetUsers!();

  @override
  Future<UserAccount> getUser(int id) => onGetUser!(id);

  @override
  Future<UserAccount> createUser(SaveUserRequest request) =>
      onCreateUser!(request);

  @override
  Future<UserAccount> updateUser(int id, SaveUserRequest request) =>
      onUpdateUser!(id, request);

  @override
  Future<UserAccount> updateUserStatus(int id, String accountStatus) =>
      onUpdateUserStatus!(id, accountStatus);

  @override
  Future<UserAccount> resetPassword(int id) => onResetPassword!(id);
}

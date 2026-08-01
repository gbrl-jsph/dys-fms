/// Authenticated user data as returned by the API.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.sectorId,
    required this.accountStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        sectorId: json['sector_id'] as int?,
        accountStatus: json['account_status'] as String,
      );

  final int id;
  final String name;
  final String email;
  final String role;
  final int? sectorId;
  final String accountStatus;

  bool get isBusinessOwner => role == 'Business Owner';
  bool get isEventManager => role == 'Event Manager';
  bool get isEmployee => role == 'Employee/Staff';
}

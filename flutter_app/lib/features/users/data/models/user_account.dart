/// User account record as returned by the Phase 2 user management API.
///
/// Used for the user list (GET /users), single user (GET /users/{id}),
/// create response (POST /users — includes `temporary_password`), and
/// update responses (PUT /users/{id}, PATCH /users/{id}/status).
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.sectorId,
    this.sectorName,
    required this.accountStatus,
    this.temporaryPassword,
    this.passwordSent,
    this.createdAt,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    sectorId: json['sector_id'] as int?,
    sectorName: json['sector_name'] as String?,
    accountStatus: json['account_status'] as String,
    temporaryPassword: json['temporary_password'] as String?,
    passwordSent: json['password_sent'] as bool?,
    createdAt: json['created_at'] as String?,
  );

  final int id;
  final String name;
  final String email;
  final String role;
  final int? sectorId;
  final String? sectorName;
  final String accountStatus;

  /// Present only in the POST /users creation response (returned once).
  final String? temporaryPassword;

  /// Whether the backend accepted the temporary-password email for
  /// delivery (create/reset responses only). `null` for older responses.
  final bool? passwordSent;

  final String? createdAt;

  bool get isBusinessOwner => role == 'Business Owner';
  bool get isEventManager => role == 'Event Manager';
  bool get isEmployee => role == 'Employee/Staff';
  bool get isActive => accountStatus == 'Active';
}

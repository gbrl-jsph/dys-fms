/// Request body shared by POST /users and PUT /users/{id}.
///
/// Mirrors the backend request fields: name, email, role, sector_id.
class SaveUserRequest {
  const SaveUserRequest({
    required this.name,
    required this.email,
    required this.role,
    required this.sectorId,
  });

  final String name;
  final String email;
  final String role;
  final int sectorId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
        'sector_id': sectorId,
      };
}

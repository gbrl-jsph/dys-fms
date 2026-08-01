/// Request body for PATCH /users/{id}/status.
///
/// Mirrors the backend request field: account_status ("Active" | "Inactive").
class UpdateUserStatusRequest {
  const UpdateUserStatusRequest({required this.accountStatus});

  final String accountStatus;

  Map<String, dynamic> toJson() => {'account_status': accountStatus};
}

/// Request body for `POST /api/expenses`.
///
/// Mirrors the backend request fields: amount, description, sector_id.
/// `sector_id` is required for the Business Owner and omitted for the
/// Event Manager (the server scopes the expense to the assigned sector);
/// `description` is optional and omitted when empty.
class SaveExpenseRequest {
  const SaveExpenseRequest({
    required this.amount,
    this.description,
    this.sectorId,
    this.recordedAt,
  });

  final double amount;
  final String? description;
  final int? sectorId;
  final DateTime? recordedAt;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (sectorId != null) 'sector_id': sectorId,
    if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
  };
}

/// Request body for `POST /api/sales`.
///
/// Mirrors the backend request fields: amount, description, sector_id.
/// `sector_id` is required for the Business Owner and omitted for the
/// Event Manager (the server scopes the sale to the assigned sector);
/// `description` is optional and omitted when empty.
class SaveSaleRequest {
  const SaveSaleRequest({
    required this.amount,
    this.description,
    this.sectorId,
  });

  final double amount;
  final String? description;
  final int? sectorId;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    if (description != null && description!.isNotEmpty)
      'description': description,
    if (sectorId != null) 'sector_id': sectorId,
  };
}

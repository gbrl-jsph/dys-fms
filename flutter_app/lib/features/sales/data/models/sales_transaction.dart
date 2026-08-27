/// A sales transaction as returned by `GET /api/sales` / `POST /api/sales`.
///
/// Sales records are immutable after creation (FR-004); no edit or delete
/// fields exist. The backend denormalizes `recorded_by` (user) and
/// `sector` (business sector) into nested objects.
class SalesTransaction {
  const SalesTransaction({
    required this.id,
    required this.amount,
    this.description,
    required this.recordedById,
    required this.recordedByName,
    required this.sectorId,
    required this.sectorName,
    required this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SalesTransaction.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> recordedBy =
        json['recorded_by'] as Map<String, dynamic>;
    final Map<String, dynamic> sector = json['sector'] as Map<String, dynamic>;

    return SalesTransaction(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      recordedById: recordedBy['id'] as int,
      recordedByName: recordedBy['name'] as String,
      sectorId: sector['id'] as int,
      sectorName: sector['name'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final int id;

  /// Transaction amount (positive decimal per the API spec).
  final double amount;

  /// Optional free-text description (nullable per the API spec).
  final String? description;

  final int recordedById;
  final String recordedByName;
  final int sectorId;
  final String sectorName;

  /// Server-assigned timestamp (`recorded_at`).
  final DateTime recordedAt;

  /// Created / updated timestamps (may be null for legacy payloads).
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

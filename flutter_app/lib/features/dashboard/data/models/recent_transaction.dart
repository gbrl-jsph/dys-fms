/// A compact dashboard representation of a sale or expense returned by the
/// existing sector-scoped transaction endpoints.
class RecentTransaction {
  const RecentTransaction({
    required this.id,
    required this.isSale,
    required this.amount,
    required this.description,
    required this.recordedAt,
  });

  factory RecentTransaction.sale(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json['id'] as int,
        isSale: true,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String?,
        recordedAt: DateTime.parse(json['recorded_at'] as String),
      );

  factory RecentTransaction.expense(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json['id'] as int,
        isSale: false,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String?,
        recordedAt: DateTime.parse(json['recorded_at'] as String),
      );

  final int id;
  final bool isSale;
  final double amount;
  final String? description;
  final DateTime recordedAt;

  /// Transaction timestamps stay in UTC internally and are localized only
  /// when shown to the signed-in user.
  DateTime get localRecordedAt => recordedAt.toLocal();
}

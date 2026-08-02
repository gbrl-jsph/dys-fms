/// Financial summary for the Dashboard stat cards (FR-002).
///
/// Parses the `GET /api/reports?type=summary` response. Two shapes are
/// defined in the API spec:
/// - single-sector: `data.sector` + `data.summary`
/// - cross-sector (Owner without sector_id): `data.cross_sector` +
///   `data.grand_total` (grand totals across all sectors)
class FinancialSummary {
  const FinancialSummary({
    required this.totalSales,
    required this.totalExpenses,
    required this.netBalance,
    this.payrollExpenses,
    this.sectorId,
    this.sectorName,
    this.isCrossSector = false,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? sector =
        json['sector'] as Map<String, dynamic>?;
    final Map<String, dynamic>? summary =
        json['summary'] as Map<String, dynamic>?;
    final Map<String, dynamic>? grandTotal =
        json['grand_total'] as Map<String, dynamic>?;

    final bool isCrossSector = json['cross_sector'] == true;
    final Map<String, dynamic> totals =
        (summary ?? grandTotal ?? const <String, dynamic>{});

    return FinancialSummary(
      totalSales: _asDouble(totals['total_sales']),
      totalExpenses: _asDouble(totals['total_expenses']),
      netBalance: _asDouble(totals['net_balance']),
      payrollExpenses: totals['payroll_expenses'] == null
          ? null
          : _asDouble(totals['payroll_expenses']),
      sectorId: sector?['id'] as int?,
      sectorName: sector?['name'] as String?,
      isCrossSector: isCrossSector,
    );
  }

  final double totalSales;
  final double totalExpenses;
  final double netBalance;
  final double? payrollExpenses;
  final int? sectorId;
  final String? sectorName;

  /// True when the report aggregates all sectors (Owner without a
  /// sector filter).
  final bool isCrossSector;

  static double _asDouble(Object? value) => value is num ? value.toDouble() : 0;
}

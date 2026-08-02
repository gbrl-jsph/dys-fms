/// Report data as returned by `GET /api/reports`.
///
/// Parses the documented response shapes (api-specification.md):
/// - per-sector / single-sector: `data.sector` + `data.summary`
/// - cross-sector (Owner without sector_id): `data.cross_sector` +
///   `data.grand_total`
/// - analytics (Owner only): `data.charts` + `data.summary`
///
/// Totals fall back across `summary` / `grand_total` so all report
/// types render the Financial Summary section.
class ReportData {
  const ReportData({
    required this.totalSales,
    required this.totalExpenses,
    required this.netBalance,
    this.payrollExpenses,
    this.sectorId,
    this.sectorName,
    this.isCrossSector = false,
    this.hasCharts = false,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? sector =
        json['sector'] as Map<String, dynamic>?;
    final Map<String, dynamic>? summary =
        json['summary'] as Map<String, dynamic>?;
    final Map<String, dynamic>? grandTotal =
        json['grand_total'] as Map<String, dynamic>?;
    final Map<String, dynamic>? charts =
        json['charts'] as Map<String, dynamic>?;

    final Map<String, dynamic> totals =
        summary ?? grandTotal ?? const <String, dynamic>{};

    return ReportData(
      totalSales: _asDouble(totals['total_sales']),
      totalExpenses: _asDouble(totals['total_expenses']),
      netBalance: _asDouble(totals['net_balance']),
      payrollExpenses: totals['payroll_expenses'] == null
          ? null
          : _asDouble(totals['payroll_expenses']),
      sectorId: sector?['id'] as int?,
      sectorName: sector?['name'] as String?,
      isCrossSector: json['cross_sector'] == true,
      hasCharts: charts != null && charts.isNotEmpty,
    );
  }

  final double totalSales;
  final double totalExpenses;
  final double netBalance;

  /// Present only in the summary report type.
  final double? payrollExpenses;

  final int? sectorId;
  final String? sectorName;

  /// True when the report aggregates all sectors (Owner without a
  /// sector filter).
  final bool isCrossSector;

  /// True when the response carries the analytics `charts` object.
  final bool hasCharts;

  static double _asDouble(Object? value) => value is num ? value.toDouble() : 0;
}

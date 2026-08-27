/// Report data as returned by `GET /api/reports`.
///
/// Parses the documented response shapes (api-specification.md):
/// - per-sector / single-sector: `data.sector` + `data.summary`
/// - cross-sector (Owner without sector_id): `data.cross_sector` +
///   `data.grand_total`
/// - analytics (Owner only): `data.charts` + `data.summary`
///
/// Totals fall back across `summary` / `grand_total` so all report
/// types render the Financial Summary section. Chart datasets
/// (`sales_trend`, `expense_breakdown`, `sector_comparison`) are
/// parsed from `data.charts` and are used to render real graphs
/// (empty arrays are valid no-data states).
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
    this.salesTrend = const [],
    this.expenseBreakdown = const [],
    this.sectorComparison = const [],
    this.crossSectorBreakdown = const [],
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

    final List<ChartPoint> salesTrend = _parseChartPoints(charts?['sales_trend']);
    final List<ChartPoint> expenseBreakdown = _parseChartPoints(charts?['expense_breakdown']);
    final List<SectorComparison> sectorComparison = _parseSectorComparison(charts?['sector_comparison']);

    // Cross-sector payload also carries a top-level `sectors` array
    // (grand_total sibling); it mirrors sector_comparison for the
    // cross-sector report type so the sector bar chart can reuse it.
    final List<SectorComparison> crossSectorBreakdown = _parseCrossSectors(json['sectors']);

    final bool hasCharts = charts != null && charts.isNotEmpty ||
        crossSectorBreakdown.isNotEmpty;

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
      hasCharts: hasCharts,
      salesTrend: salesTrend,
      expenseBreakdown: expenseBreakdown,
      sectorComparison: sectorComparison.isNotEmpty ? sectorComparison : crossSectorBreakdown,
      crossSectorBreakdown: crossSectorBreakdown,
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

  /// True when the response carries the analytics `charts` object
  /// or a cross-sector `sectors` array.
  final bool hasCharts;

  /// Monthly sales trend: [{label: "2026-07", total: 150000}, ...]
  final List<ChartPoint> salesTrend;

  /// Monthly expense breakdown: [{label: "2026-07", total: 85000}, ...]
  final List<ChartPoint> expenseBreakdown;

  /// Per-sector comparison (analytics + cross-sector charts).
  final List<SectorComparison> sectorComparison;

  /// Raw cross-sector `sectors` array (Owner without sector_id).
  final List<SectorComparison> crossSectorBreakdown;

  static double _asDouble(Object? value) => value is num ? value.toDouble() : 0;

  static List<ChartPoint> _parseChartPoints(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ChartPoint.fromJson)
        .toList();
  }

  static List<SectorComparison> _parseSectorComparison(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(SectorComparison.fromJson)
        .toList();
  }

  static List<SectorComparison> _parseCrossSectors(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(SectorComparison.fromJson)
        .toList();
  }
}

/// Single point in a time-series chart (sales_trend / expense_breakdown).
class ChartPoint {
  const ChartPoint({required this.label, required this.total});

  factory ChartPoint.fromJson(Map<String, dynamic> json) => ChartPoint(
        label: json['label'] as String? ?? '',
        total: ReportData._asDouble(json['total']),
      );

  final String label;
  final double total;
}

/// Per-sector comparison entry (sector_comparison / cross-sector sectors).
class SectorComparison {
  const SectorComparison({
    required this.id,
    required this.name,
    required this.totalSales,
    required this.totalExpenses,
    required this.netBalance,
  });

  factory SectorComparison.fromJson(Map<String, dynamic> json) => SectorComparison(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        totalSales: ReportData._asDouble(json['total_sales']),
        totalExpenses: ReportData._asDouble(json['total_expenses']),
        netBalance: ReportData._asDouble(json['net_balance']),
      );

  final int id;
  final String name;
  final double totalSales;
  final double totalExpenses;
  final double netBalance;
}

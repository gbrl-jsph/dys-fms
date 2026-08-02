import 'package:dio/dio.dart';

import 'package:dys_fms/features/reports/data/models/report_data.dart';
import 'package:dys_fms/features/reports/data/repositories/reports_repository.dart';

/// Sample per-sector summary payload matching the API spec `data`.
const Map<String, dynamic> summaryReportJson = {
  'sector': {'id': 1, 'name': 'DYS Events'},
  'summary': {
    'total_sales': 150000.00,
    'total_expenses': 85000.00,
    'net_balance': 65000.00,
    'payroll_expenses': 40000.00,
  },
  'period': {'date_from': '2026-01-01', 'date_to': '2026-07-28'},
};

/// Sample cross-sector payload (Owner without sector_id).
const Map<String, dynamic> crossSectorReportJson = {
  'cross_sector': true,
  'sectors': [
    {
      'id': 1,
      'name': 'DYS Events',
      'total_sales': 150000.00,
      'total_expenses': 85000.00,
      'net_balance': 65000.00,
    },
    {
      'id': 2,
      'name': 'B&DYS',
      'total_sales': 75000.00,
      'total_expenses': 32000.00,
      'net_balance': 43000.00,
    },
  ],
  'grand_total': {
    'total_sales': 225000.00,
    'total_expenses': 117000.00,
    'net_balance': 108000.00,
  },
  'period': {'date_from': '2026-01-01', 'date_to': '2026-07-28'},
};

/// Sample analytics payload (Business Owner only).
const Map<String, dynamic> analyticsReportJson = {
  'charts': {
    'sales_trend': [],
    'expense_breakdown': [],
    'sector_comparison': [],
  },
  'summary': {
    'total_sales': 225000.00,
    'total_expenses': 117000.00,
    'net_balance': 108000.00,
  },
};

ReportData buildSummaryReport() => ReportData.fromJson(summaryReportJson);

ReportData buildCrossSectorReport() =>
    ReportData.fromJson(crossSectorReportJson);

ReportData buildAnalyticsReport() => ReportData.fromJson(analyticsReportJson);

/// In-memory [ReportsRepository] fake with an overridable callback.
class FakeReportsRepository implements ReportsRepository {
  Future<ReportData> Function({
    required String type,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? sectorId,
  })?
  onGetReport;

  @override
  late final Dio dio = Dio();

  @override
  Future<ReportData> getReport({
    required String type,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? sectorId,
  }) => onGetReport!(
    type: type,
    dateFrom: dateFrom,
    dateTo: dateTo,
    sectorId: sectorId,
  );
}

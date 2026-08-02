import 'package:dio/dio.dart';

import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/data/repositories/dashboard_repository.dart';

/// Sample `GET /api/reports?type=summary` single-sector payloads matching
/// the API spec `data` object.
const Map<String, dynamic> summaryResponseData = {
  'sector': {'id': 1, 'name': 'DYS Events'},
  'summary': {
    'total_sales': 150000.00,
    'total_expenses': 85000.00,
    'net_balance': 65000.00,
    'payroll_expenses': 40000.00,
  },
  'period': {'date_from': '2026-01-01', 'date_to': '2026-07-28'},
};

const Map<String, dynamic> summaryResponseBody = {
  'data': summaryResponseData,
  'message': 'Report generated successfully.',
};

const Map<String, dynamic> crossSectorResponseData = {
  'cross_sector': true,
  'sectors': [
    {
      'id': 1,
      'name': 'DYS Events',
      'total_sales': 150000.00,
      'total_expenses': 85000.00,
      'net_balance': 65000.00,
    },
  ],
  'grand_total': {
    'total_sales': 225000.00,
    'total_expenses': 117000.00,
    'net_balance': 108000.00,
  },
  'period': {'date_from': '2026-01-01', 'date_to': '2026-07-28'},
};

const Map<String, dynamic> crossSectorResponseBody = {
  'data': crossSectorResponseData,
  'message': 'Cross-sector report generated successfully.',
};

/// In-memory [DashboardRepository] fake with overridable callbacks.
class FakeDashboardRepository implements DashboardRepository {
  Future<FinancialSummary> Function(int? sectorId)? onGetSummary;

  @override
  late final Dio dio = Dio();

  @override
  Future<FinancialSummary> getSummary({int? sectorId}) =>
      onGetSummary!(sectorId);
}

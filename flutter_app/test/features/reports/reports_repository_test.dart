import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/reports/data/models/report_data.dart';
import 'package:dys_fms/features/reports/data/repositories/reports_repository.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_reports_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late ReportsRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = ReportsRepository(ApiClient.instance);
  });

  test(
    'getReport() GETs /reports with the type and parses the summary',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': summaryReportJson,
          'message': 'Report generated successfully.',
        });
      };

      final ReportData report = await repository.getReport(type: 'summary');

      expect(captured?.path, '/reports');
      expect(captured?.method, 'GET');
      expect(captured?.queryParameters, {'type': 'summary'});
      expect(report.totalSales, 150000.00);
      expect(report.totalExpenses, 85000.00);
      expect(report.netBalance, 65000.00);
      expect(report.payrollExpenses, 40000.00);
      expect(report.sectorId, 1);
      expect(report.sectorName, 'DYS Events');
      expect(report.isCrossSector, isFalse);
      expect(report.hasCharts, isTrue);
      expect(report.salesTrend, isNotEmpty);
      expect(report.expenseBreakdown, isNotEmpty);
      expect(report.sectorComparison, isNotEmpty);
      expect(report.salesTrend.first.label, '2026-07');
      expect(report.salesTrend.first.total, 150000.00);
    },
  );

  test('getReport() sends date_from, date_to, and sector_id in YYYY-MM-DD '
      'format', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': summaryReportJson,
        'message': 'Report generated successfully.',
      });
    };

    await repository.getReport(
      type: 'sales',
      dateFrom: DateTime(2026, 1, 1),
      dateTo: DateTime(2026, 7, 28),
      sectorId: 2,
    );

    expect(captured?.queryParameters, {
      'type': 'sales',
      'date_from': '2026-01-01',
      'date_to': '2026-07-28',
      'sector_id': 2,
    });
  });

  test(
    'getReport() omits the date and sector filters when not provided',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': summaryReportJson,
          'message': 'Report generated successfully.',
        });
      };

      await repository.getReport(type: 'expenses');

      expect(captured?.queryParameters, {'type': 'expenses'});
    },
  );

  test('getReport() parses the Owner cross-sector aggregate', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': crossSectorReportJson,
      'message': 'Cross-sector report generated successfully.',
    });

    final ReportData report = await repository.getReport(type: 'summary');

    expect(report.isCrossSector, isTrue);
    expect(report.totalSales, 225000.00);
    expect(report.totalExpenses, 117000.00);
    expect(report.netBalance, 108000.00);
    expect(report.payrollExpenses, isNull);
    expect(report.sectorId, isNull);
  });

  test('getReport() parses the analytics payload with charts', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': analyticsReportJson,
      'message': 'Analytics report generated successfully.',
    });

    final ReportData report = await repository.getReport(type: 'analytics');

    expect(report.hasCharts, isTrue);
    expect(report.totalSales, 225000.00);
    expect(report.totalExpenses, 117000.00);
    expect(report.netBalance, 108000.00);
  });

  test('propagates the DioException on failure (403)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getReport(type: 'summary'),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response?.data as Map<String, dynamic>)['message'],
          'message',
          'Forbidden.',
        ),
      ),
    );
  });
}

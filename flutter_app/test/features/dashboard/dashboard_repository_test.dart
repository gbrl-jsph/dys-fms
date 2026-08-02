import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/data/repositories/dashboard_repository.dart';

import '../../helpers/fake_dashboard_repository.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late DashboardRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = DashboardRepository(ApiClient.instance);
  });

  test(
    'getSummary() requests type=summary and parses the sector summary',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, summaryResponseBody);
      };

      final FinancialSummary summary = await repository.getSummary(sectorId: 1);

      expect(captured?.path, '/reports');
      expect(captured?.method, 'GET');
      expect(captured?.queryParameters, {'type': 'summary', 'sector_id': 1});

      expect(summary.totalSales, 150000.00);
      expect(summary.totalExpenses, 85000.00);
      expect(summary.netBalance, 65000.00);
      expect(summary.payrollExpenses, 40000.00);
      expect(summary.sectorId, 1);
      expect(summary.sectorName, 'DYS Events');
      expect(summary.isCrossSector, isFalse);
    },
  );

  test('getSummary() omits sector_id when none is provided', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, summaryResponseBody);
    };

    await repository.getSummary();

    expect(captured?.queryParameters, {'type': 'summary'});
  });

  test('getSummary() parses the cross-sector shape for the Owner', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(200, crossSectorResponseBody);

    final FinancialSummary summary = await repository.getSummary();

    expect(summary.isCrossSector, isTrue);
    expect(summary.totalSales, 225000.00);
    expect(summary.totalExpenses, 117000.00);
    expect(summary.netBalance, 108000.00);
    expect(summary.payrollExpenses, isNull);
    expect(summary.sectorId, isNull);
  });

  test('getSummary() propagates the DioException on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getSummary(sectorId: 1),
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

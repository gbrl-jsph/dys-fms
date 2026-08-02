import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/reports/data/repositories/reports_repository.dart';
import 'package:dys_fms/features/reports/domain/reports_state.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_reports_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late ReportsRepository repository;
  late ReportsProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = ReportsRepository(ApiClient.instance);
    provider = ReportsProvider(repository);
  });

  test(
    'generateReport() publishes loading then the generated report',
    () async {
      adapter.onRequest = (options) async => jsonResponse(200, {
        'data': summaryReportJson,
        'message': 'Report generated successfully.',
      });

      expect(provider.state.isLoading, isFalse);
      expect(provider.state.report, isNull);

      final Future<void> generate = provider.generateReport(
        type: 'summary',
        sectorId: 1,
      );

      expect(provider.state.isLoading, isTrue);

      await generate;

      final ReportsState state = provider.state;
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.report, isNotNull);
      expect(state.report?.totalSales, 150000.00);
      expect(state.report?.netBalance, 65000.00);
    },
  );

  test('generateReport() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.generateReport(type: 'summary');

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.report, isNull);
    expect(provider.state.error, 'Forbidden.');
  });

  test('generateReport() surfaces the analytics charts flag', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': analyticsReportJson,
      'message': 'Analytics report generated successfully.',
    });

    await provider.generateReport(type: 'analytics');

    expect(provider.state.report?.hasCharts, isTrue);
    expect(provider.state.report?.totalSales, 225000.00);
  });

  test('clearError() resets the error field', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});
    await provider.generateReport(type: 'summary');
    expect(provider.state.error, isNotNull);

    provider.clearError();
    expect(provider.state.error, isNull);
    expect(provider.state.report, isNull);
  });

  test('clearReport() discards the generated report and the error', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': summaryReportJson,
      'message': 'Report generated successfully.',
    });
    await provider.generateReport(type: 'summary');
    expect(provider.state.report, isNotNull);

    provider.clearReport();
    expect(provider.state.report, isNull);
    expect(provider.state.error, isNull);
  });

  test('propagates the DioException from the repository', () async {
    adapter.onRequest = (options) async =>
        throw DioException(requestOptions: RequestOptions(path: '/reports'));

    await provider.generateReport(type: 'summary');

    expect(provider.state.error, 'Something went wrong. Please try again.');
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/events/financial_events.dart';
import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/dashboard/data/models/financial_summary.dart';
import 'package:dys_fms/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:dys_fms/features/dashboard/domain/dashboard_state.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';

import '../../helpers/fake_dashboard_repository.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late DashboardRepository repository;
  late DashboardProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = DashboardRepository(ApiClient.instance);
    provider = DashboardProvider(repository);
  });

  const FinancialSummary sampleSummary = FinancialSummary(
    totalSales: 150000,
    totalExpenses: 85000,
    netBalance: 65000,
    payrollExpenses: 40000,
    sectorId: 1,
    sectorName: 'DYS Events',
  );

  test('loadSummary() publishes loading then the loaded summary', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(200, summaryResponseBody);

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.summary, isNull);

    final Future<void> load = provider.loadSummary(sectorId: 1);

    expect(provider.state.isLoading, isTrue);

    await load;

    final DashboardState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.summary?.totalSales, sampleSummary.totalSales);
    expect(state.summary?.totalExpenses, sampleSummary.totalExpenses);
    expect(state.summary?.netBalance, sampleSummary.netBalance);
    expect(state.summary?.sectorName, 'DYS Events');
  });

  test('loadSummary() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(500, {'message': 'Internal server error.'});

    await provider.loadSummary(sectorId: 1);

    final DashboardState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.summary, isNull);
    expect(state.error, 'Internal server error.');
  });

  test(
    'loadSummary() maps network failures to the connection message',
    () async {
      adapter.onRequest = (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );

      await provider.loadSummary();

      expect(
        provider.state.error,
        'Unable to connect to the server. Please try again.',
      );
    },
  );

  test('clearError() clears the published error', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(500, {'message': 'Internal server error.'});

    await provider.loadSummary();
    expect(provider.state.error, isNotNull);

    provider.clearError();

    expect(provider.state.error, isNull);
  });

  test('reloads the summary for the current sector on financial events', () async {
    final FinancialEvents events = FinancialEvents();
    provider = DashboardProvider(repository, financialEvents: events);

    int requestCount = 0;
    adapter.onRequest = (options) async {
      requestCount++;
      return jsonResponse(200, summaryResponseBody);
    };

    await provider.loadSummary(sectorId: 1);
    expect(requestCount, 1);

    events.notifyDataChanged();
    await pumpEventQueue();

    expect(requestCount, 2);
    expect(provider.state.summary?.sectorId, 1);
    expect(provider.state.summary?.sectorName, 'DYS Events');
  });
}

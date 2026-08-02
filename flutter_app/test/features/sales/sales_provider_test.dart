import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/events/financial_events.dart';
import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/sales/data/models/save_sale_request.dart';
import 'package:dys_fms/features/sales/data/repositories/sales_repository.dart';
import 'package:dys_fms/features/sales/domain/sales_state.dart';
import 'package:dys_fms/features/sales/presentation/providers/sales_provider.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_sales_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late SalesRepository repository;
  late SalesProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = SalesRepository(ApiClient.instance);
    provider = SalesProvider(repository);
  });

  test('loadSales() publishes loading then the loaded transactions', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': [saleJson, secondSaleJson],
      'message': 'Sales transactions retrieved successfully.',
    });

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.sales, isEmpty);

    final Future<void> load = provider.loadSales(sectorId: 1);

    expect(provider.state.isLoading, isTrue);

    await load;

    final SalesState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.sales, hasLength(2));
    expect(state.sales.first.amount, 15000.00);
    expect(state.sales.first.sectorName, 'DYS Events');
  });

  test('loadSales() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.loadSales();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.error, 'Forbidden.');
    expect(provider.state.sales, isEmpty);
  });

  test(
    'recordSale() submits, refreshes the list, and publishes success',
    () async {
      SaveSaleRequest? sentRequest;
      adapter.onRequest = (options) async {
        if (options.method == 'POST') {
          final Map<String, dynamic> body =
              options.data as Map<String, dynamic>;
          sentRequest = SaveSaleRequest(
            amount: (body['amount'] as num).toDouble(),
            description: body['description'] as String?,
            sectorId: body['sector_id'] as int?,
          );
          return jsonResponse(201, {
            'data': saleJson,
            'message': 'Sale recorded successfully.',
          });
        }
        return jsonResponse(200, {
          'data': [saleJson],
          'message': 'Sales transactions retrieved successfully.',
        });
      };

      final Future<void> record = provider.recordSale(
        const SaveSaleRequest(
          amount: 15000,
          description: 'Full event coordination package',
          sectorId: 1,
        ),
        sectorId: 1,
      );

      expect(provider.state.isSubmitting, isTrue);

      await record;

      final SalesState state = provider.state;
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
      expect(state.successMessage, 'Sale recorded successfully.');
      expect(state.sales, hasLength(1));
      expect(sentRequest?.amount, 15000.00);
      expect(sentRequest?.sectorId, 1);
    },
  );

  test('recordSale() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.recordSale(const SaveSaleRequest(amount: 0));

    expect(provider.state.isSubmitting, isFalse);
    expect(provider.state.successMessage, isNull);
    expect(provider.state.error, 'Forbidden.');
  });

  test('clearSuccess() and clearError() reset the feedback fields', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});
    await provider.loadSales();
    expect(provider.state.error, isNotNull);

    provider.clearError();
    expect(provider.state.error, isNull);

    adapter.onRequest = (options) async {
      if (options.method == 'POST') {
        return jsonResponse(201, {
          'data': saleJson,
          'message': 'Sale recorded successfully.',
        });
      }
      return jsonResponse(200, {
        'data': [saleJson],
        'message': 'Sales transactions retrieved successfully.',
      });
    };
    await provider.recordSale(const SaveSaleRequest(amount: 100));
    expect(provider.state.successMessage, isNotNull);

    provider.clearSuccess();
    expect(provider.state.successMessage, isNull);
  });

  test('propagates the DioException from the repository', () async {
    adapter.onRequest = (options) async =>
        throw DioException(requestOptions: RequestOptions(path: '/sales'));

    await provider.loadSales();

    expect(provider.state.error, 'Something went wrong. Please try again.');
  });

  test('recordSale() notifies financial events after a success', () async {
    final FinancialEvents events = FinancialEvents();
    int notifications = 0;
    events.addListener(() => notifications++);
    provider = SalesProvider(repository, financialEvents: events);

    adapter.onRequest = (options) async {
      if (options.method == 'POST') {
        return jsonResponse(201, {
          'data': saleJson,
          'message': 'Sale recorded successfully.',
        });
      }
      return jsonResponse(200, {
        'data': [saleJson],
        'message': 'Sales transactions retrieved successfully.',
      });
    };

    await provider.recordSale(const SaveSaleRequest(amount: 100, sectorId: 1));

    expect(notifications, 1);
  });

  test('recordSale() does not notify financial events on failure', () async {
    final FinancialEvents events = FinancialEvents();
    int notifications = 0;
    events.addListener(() => notifications++);
    provider = SalesProvider(repository, financialEvents: events);

    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.recordSale(const SaveSaleRequest(amount: 100));

    expect(provider.state.error, 'Forbidden.');
    expect(notifications, 0);
  });
}

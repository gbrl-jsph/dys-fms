import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/sales/data/models/save_sale_request.dart';
import 'package:dys_fms/features/sales/data/models/sales_transaction.dart';
import 'package:dys_fms/features/sales/data/repositories/sales_repository.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_sales_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late SalesRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = SalesRepository(ApiClient.instance);
  });

  test(
    'getSales() GETs /sales without a sector filter and parses the list',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': [saleJson, secondSaleJson],
          'message': 'Sales transactions retrieved successfully.',
        });
      };

      final List<SalesTransaction> sales = await repository.getSales();

      expect(captured?.path, '/sales');
      expect(captured?.method, 'GET');
      expect(captured?.queryParameters, <String, dynamic>{});
      expect(sales, hasLength(2));
      expect(sales.first.id, 101);
      expect(sales.first.amount, 15000.00);
      expect(sales.first.description, 'Full event coordination package');
      expect(sales.first.recordedById, 1);
      expect(sales.first.recordedByName, 'Juan Dela Cruz');
      expect(sales.first.sectorId, 1);
      expect(sales.first.sectorName, 'DYS Events');
      expect(sales.first.recordedAt.toUtc().hour, 14);
      expect(sales.last.description, isNull);
    },
  );

  test(
    'getSales() includes sector_id when the Owner filters by sector',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': [saleJson],
          'message': 'Sales transactions retrieved successfully.',
        });
      };

      await repository.getSales(sectorId: 2);

      expect(captured?.queryParameters, {'sector_id': 2});
    },
  );

  test(
    'recordSale() POSTs /sales with amount, description, and sector_id',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(201, {
          'data': saleJson,
          'message': 'Sale recorded successfully.',
        });
      };

      final SalesTransaction sale = await repository.recordSale(
        const SaveSaleRequest(
          amount: 25000,
          description: 'Birthday party package',
          sectorId: 1,
        ),
      );

      expect(captured?.path, '/sales');
      expect(captured?.method, 'POST');
      expect(captured?.data, {
        'amount': 25000,
        'description': 'Birthday party package',
        'sector_id': 1,
      });
      expect(sale.id, 101);
    },
  );

  test(
    'recordSale() omits description and sector_id for an Event Manager',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(201, {
          'data': saleJson,
          'message': 'Sale recorded successfully.',
        });
      };

      await repository.recordSale(const SaveSaleRequest(amount: 5000));

      expect(captured?.data, {'amount': 5000});
    },
  );

  test('propagates the DioException on failure (403)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.getSales(),
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

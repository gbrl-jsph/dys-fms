import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/sectors/data/models/business_sector.dart';
import 'package:dys_fms/features/sectors/data/repositories/sectors_repository.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_sectors_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late SectorsRepository repository;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = SectorsRepository(ApiClient.instance);
  });

  test(
    'getSectors() GETs /business-sectors and parses the four sectors',
    () async {
      RequestOptions? captured;
      adapter.onRequest = (options) async {
        captured = options;
        return jsonResponse(200, {
          'data': businessSectorsJson,
          'message': 'Business sectors retrieved successfully.',
        });
      };

      final List<BusinessSector> sectors = await repository.getSectors();

      expect(captured?.path, '/business-sectors');
      expect(captured?.method, 'GET');
      expect(sectors, hasLength(4));
      expect(sectors.first.id, 1);
      expect(sectors.first.name, 'DYS Events');
      expect(
        sectors.first.description,
        'Event coordination and styling main branch',
      );
      expect(sectors.last.id, 4);
      expect(sectors.last.name, 'SnapDYS Memories');
      expect(sectors.last.description, 'Video guestbook');
    },
  );

  test('switchSector() POSTs /business-sectors/switch with sector_id and '
      'parses the previous + current sectors', () async {
    RequestOptions? captured;
    adapter.onRequest = (options) async {
      captured = options;
      return jsonResponse(200, {
        'data': switchSectorResponseJson,
        'message': 'Sector switched successfully.',
      });
    };

    final SectorSwitchResult result = await repository.switchSector(2);

    expect(captured?.path, '/business-sectors/switch');
    expect(captured?.method, 'POST');
    expect(captured?.data, {'sector_id': 2});
    expect(result.previousSector.id, 1);
    expect(result.previousSector.name, 'DYS Events');
    expect(result.currentSector.id, 2);
    expect(result.currentSector.name, 'B&DYS');
  });

  test(
    'propagates the DioException on failure (422 validation error)',
    () async {
      adapter.onRequest = (options) async => jsonResponse(422, {
        'message': 'Validation failed.',
        'errors': {
          'sector_id': ['The selected sector_id is invalid.'],
        },
      });

      await expectLater(
        repository.switchSector(99),
        throwsA(
          isA<DioException>().having(
            (e) => (e.response?.data as Map<String, dynamic>)['message'],
            'message',
            'Validation failed.',
          ),
        ),
      );
    },
  );

  test('propagates the DioException on failure (403 forbidden)', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await expectLater(
      repository.switchSector(2),
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

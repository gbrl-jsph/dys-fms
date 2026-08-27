import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/sectors/data/models/business_sector.dart';
import 'package:dys_fms/features/sectors/data/repositories/sectors_repository.dart';
import 'package:dys_fms/features/sectors/domain/sectors_state.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_sectors_repository.dart';

void main() {
  late FakeHttpClientAdapter adapter;
  late SectorsRepository repository;
  late SectorsProvider provider;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    ApiClient.init(tokenProvider: () async => null, httpClientAdapter: adapter);
    repository = SectorsRepository(ApiClient.instance);
    provider = SectorsProvider(repository);
  });

  test('loadSectors() publishes loading then the loaded sectors', () async {
    adapter.onRequest = (options) async => jsonResponse(200, {
      'data': businessSectorsJson,
      'message': 'Business sectors retrieved successfully.',
    });

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.sectors, isEmpty);

    final Future<void> load = provider.loadSectors();

    expect(provider.state.isLoading, isTrue);

    await load;

    final SectorsState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.sectors, hasLength(4));
    expect(state.sectors.first.name, 'DYS Events');
    expect(state.sectors.last.name, 'SnapDYS Memories');
  });

  test('loadSectors() publishes the error message on failure', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(401, {'message': 'Unauthenticated.'});

    await provider.loadSectors();

    expect(provider.state.isLoading, isFalse);
    expect(provider.state.error, 'Unauthenticated.');
    expect(provider.state.sectors, isEmpty);
  });

  test(
    'switchSector() publishes isSwitching then returns the acknowledgement',
    () async {
      adapter.onRequest = (options) async => jsonResponse(200, {
        'data': switchSectorResponseJson,
        'message': 'Sector switched successfully.',
      });

      final Future<SectorSwitchResult?> switchFuture = provider.switchSector(2);

      expect(provider.state.isSwitching, isTrue);

      final result = await switchFuture;

      final SectorsState state = provider.state;
      expect(state.isSwitching, isFalse);
      expect(state.error, isNull);
      expect(result, isNotNull);
      expect(result!.previousSector!.id, 1);
      expect(result.previousSector!.name, 'DYS Events');
      expect(result.currentSector.id, 2);
      expect(result.currentSector.name, 'B&DYS');
    },
  );

  test(
    'switchSector() publishes the error and returns null on failure',
    () async {
      adapter.onRequest = (options) async => jsonResponse(422, {
        'message': 'Validation failed.',
        'errors': {
          'sector_id': ['The selected sector_id is invalid.'],
        },
      });

      final result = await provider.switchSector(99);

      expect(provider.state.isSwitching, isFalse);
      expect(provider.state.error, 'Validation failed.');
      expect(result, isNull);
    },
  );

  test('clearError() clears the published error', () async {
    adapter.onRequest = (options) async =>
        jsonResponse(403, {'message': 'Forbidden.'});

    await provider.switchSector(2);
    expect(provider.state.error, 'Forbidden.');

    provider.clearError();

    expect(provider.state.error, isNull);
  });
}

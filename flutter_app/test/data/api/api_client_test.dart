import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/data/api/api_config.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  test(
    'VM client uses API configuration and attaches the bearer token',
    () async {
      final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
      RequestOptions? captured;
      adapter.onRequest = (RequestOptions options) async {
        captured = options;
        return jsonResponse(200, <String, dynamic>{});
      };

      ApiClient.init(
        tokenProvider: () async => 'native-token',
        tokenClearer: () async {},
        httpClientAdapter: adapter,
      );

      final Dio dio = ApiClient.instance.dio;
      await dio.get<void>('/native-check');

      expect(dio.options.baseUrl, ApiConfig.baseUrl);
      expect(dio.options.connectTimeout, ApiConfig.timeout);
      expect(dio.options.receiveTimeout, ApiConfig.timeout);
      expect(captured?.headers['Authorization'], 'Bearer native-token');
    },
  );
}

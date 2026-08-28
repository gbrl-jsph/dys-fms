import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_interceptor.dart';

/// Global Dio HTTP client singleton.
///
/// Configured from [ApiConfig] (base URL, timeouts) with default JSON
/// headers and the [AuthInterceptor] registered so every request
/// automatically carries the bearer token.
class ApiClient {
  ApiClient._({
    required Future<String?> Function() tokenProvider,
    required Future<void> Function() tokenClearer,
    HttpClientAdapter? httpClientAdapter,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.add(AuthInterceptor(
        tokenProvider: tokenProvider,
        tokenClearer: tokenClearer,
      ));

    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }
  }

  static ApiClient? _instance;

  /// The initialized singleton instance.
  ///
  /// Throws if [init] has not been called yet.
  static ApiClient get instance {
    final ApiClient? instance = _instance;
    if (instance == null) {
      throw StateError('ApiClient.init() must be called before use.');
    }
    return instance;
  }

  /// Initializes the singleton, wiring the token provider from the
  /// secure storage abstraction into the auth interceptor.
  ///
  /// Must be called once during app startup. [httpClientAdapter] is a
  /// test-only override used to serve canned HTTP responses.
  static void init({
    required Future<String?> Function() tokenProvider,
    required Future<void> Function() tokenClearer,
    HttpClientAdapter? httpClientAdapter,
  }) {
    _instance = ApiClient._(
      tokenProvider: tokenProvider,
      tokenClearer: tokenClearer,
      httpClientAdapter: httpClientAdapter,
    );
  }

  late final Dio _dio;

  /// The configured Dio instance.
  Dio get dio => _dio;
}

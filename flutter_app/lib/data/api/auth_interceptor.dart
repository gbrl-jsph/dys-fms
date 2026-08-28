import 'package:dio/dio.dart';

/// Attaches the bearer token to outgoing requests and clears the
/// stored token when the API returns 401 (Unauthenticated).
///
/// The token is obtained exclusively through the injected
/// [tokenProvider] function, which resolves to the secure storage
/// abstraction (`SecureStorage.getToken`) once wired in `main.dart`.
/// No other storage or persistence mechanism is referenced here.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.tokenClearer,
  });

  /// Reads the current auth token from secure storage.
  ///
  /// Returns `null` when the user is not authenticated.
  final Future<String?> Function() tokenProvider;

  /// Clears the stored token from secure storage (called on 401).
  final Future<void> Function() tokenClearer;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await tokenProvider();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await tokenClearer();
    }
    handler.next(err);
  }
}

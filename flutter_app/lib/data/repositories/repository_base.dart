import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Base class for all feature repositories.
///
/// Standardizes ownership of the shared [ApiClient] (whose [Dio] instance
/// has the auth interceptor attached) so feature repositories only
/// declare their endpoints. No business logic lives in this base class.
abstract class Repository {
  Repository(this._apiClient);

  final ApiClient _apiClient;

  /// The shared [Dio] instance with the bearer-token interceptor.
  Dio get dio => _apiClient.dio;
}

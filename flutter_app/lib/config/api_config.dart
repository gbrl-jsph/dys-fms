/// Application-wide API configuration.
///
/// Matches the approved API Specification:
/// - Base URL: http://localhost:8000/api (dev default)
/// - Endpoint constants for all Phase 1 authentication routes
/// - Endpoint constants/methods for all Phase 2 user management routes
class ApiConfig {
  ApiConfig._();

  /// Base URL for all API requests (dev default per Phase 1 Implementation Plan §4.2).
  static const String baseUrl = 'http://localhost:8000/api';

  /// Connection and receive timeout for all HTTP requests (30 seconds).
  static const Duration timeout = Duration(seconds: 30);

  /// POST /api/login — authenticate user and receive Sanctum token.
  static const String loginEndpoint = '/login';

  /// POST /api/logout — revoke the current Sanctum token.
  static const String logoutEndpoint = '/logout';

  /// GET /api/users — list all users.
  static const String usersEndpoint = '/users';

  /// GET /api/users/{id} — retrieve a single user.
  static String userEndpoint(int id) => '/users/$id';

  /// PATCH /api/users/{id}/status — activate/deactivate a user.
  static String userStatusEndpoint(int id) => '/users/$id/status';
}

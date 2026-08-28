/// Application-wide API configuration.
///
/// Matches the approved API Specification:
/// - Base URL: http://localhost:8000/api (dev default)
/// - Endpoint constants for all Phase 1 authentication routes
/// - Endpoint constants/methods for all Phase 2 user management routes
/// - Endpoint constants for all Phase 8 report routes
class ApiConfig {
  ApiConfig._();

  /// Base URL for all API requests (production).
  static const String baseUrl = 'https://dys-fms.onrender.com/api';

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

  /// POST /api/users/{id}/reset-password — generate a new one-time
  /// temporary password for a user.
  static String userResetPasswordEndpoint(int id) =>
      '/users/$id/reset-password';

  /// GET /api/reports — generate a report (type: summary/sales/expenses/analytics).
  static const String reportsEndpoint = '/reports';

  /// GET /api/sales, POST /api/sales — list and record sales transactions.
  static const String salesEndpoint = '/sales';

  /// GET /api/sales/{id}, PUT /api/sales/{id}, DELETE /api/sales/{id}
  static String saleEndpoint(int id) => '/sales/$id';

  /// GET /api/expenses, POST /api/expenses — list and record expenses.
  static const String expensesEndpoint = '/expenses';

  /// GET /api/expenses/{id}, PUT /api/expenses/{id}, DELETE /api/expenses/{id}
  static String expenseEndpoint(int id) => '/expenses/$id';

  /// GET /api/profile, PUT /api/profile, POST /api/change-password
  static const String profileEndpoint = '/profile';
  static const String changePasswordEndpoint = '/change-password';
  static const String forgotPasswordEndpoint = '/forgot-password';
  static const String resetPasswordEndpoint = '/reset-password';

  /// GET /api/payroll, POST /api/payroll — list payroll records and
  /// calculate/save payroll.
  static const String payrollEndpoint = '/payroll';

  /// GET /api/business-sectors — list the four approved business sectors.
  static const String businessSectorsEndpoint = '/business-sectors';

  /// POST /api/business-sectors/switch — switch the current sector
  /// context (Business Owner only; stateless on the server).
  static const String businessSectorsSwitchEndpoint =
      '/business-sectors/switch';
}

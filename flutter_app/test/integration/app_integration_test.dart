import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/core/theme/theme_controller.dart';
import 'package:dys_fms/core/theme/theme_mode_store.dart';
import 'package:dys_fms/core/widgets/app_avatar.dart';
import 'package:dys_fms/data/api/api_client.dart';
import 'package:dys_fms/features/auth/data/repositories/auth_repository.dart';
import 'package:dys_fms/features/auth/data/storage/secure_storage.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:dys_fms/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dys_fms/features/expenses/data/repositories/expenses_repository.dart';
import 'package:dys_fms/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:dys_fms/features/payroll/data/repositories/payroll_repository.dart';
import 'package:dys_fms/features/payroll/presentation/providers/payroll_provider.dart';
import 'package:dys_fms/features/reports/data/repositories/reports_repository.dart';
import 'package:dys_fms/features/reports/presentation/providers/reports_provider.dart';
import 'package:dys_fms/features/sales/data/repositories/sales_repository.dart';
import 'package:dys_fms/features/sales/presentation/providers/sales_provider.dart';
import 'package:dys_fms/features/sectors/data/repositories/sectors_repository.dart';
import 'package:dys_fms/features/sectors/presentation/providers/sectors_provider.dart';
import 'package:dys_fms/features/users/data/repositories/users_repository.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_dashboard_repository.dart';
import '../helpers/fake_expenses_repository.dart';
import '../helpers/fake_http_adapter.dart';
import '../helpers/fake_payroll_repository.dart';
import '../helpers/fake_sales_repository.dart';
import '../helpers/fake_sectors_repository.dart';
import '../helpers/fake_users_repository.dart';

/// Event Manager login payload (second business: B&DYS).
const Map<String, dynamic> eventManagerLoginJson = {
  'data': {
    'user': mariaUserJson,
    'token': '2|test-token',
    'default_sector': {'id': 2, 'name': 'B&DYS'},
  },
  'message': 'Login successful.',
};

/// Owner login payload (default sector: DYS Events).
Map<String, dynamic> ownerLoginJson() => {
  'data': {
    'user': ownerUserJson,
    'token': '1|test-token',
    'default_sector': {'id': 1, 'name': 'DYS Events'},
  },
  'message': 'Login successful.',
};

/// In-memory [FlutterSecureStorage] so the real [SecureStorage] path
/// (token + user persistence) works inside widget tests.
class _InMemoryFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values.containsKey(key);

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map<String, String>.of(_values);

  @override
  void registerListener({
    required String key,
    required ValueChanged<String?> listener,
  }) {}

  @override
  void unregisterListener({
    required String key,
    required ValueChanged<String?> listener,
  }) {}

  @override
  void unregisterAllListenersForKey({required String key}) {}

  @override
  void unregisterAllListeners() {}

  @override
  IOSOptions get iOptions => IOSOptions.defaultOptions;

  @override
  AndroidOptions get aOptions => AndroidOptions.defaultOptions;

  @override
  LinuxOptions get lOptions => LinuxOptions.defaultOptions;

  @override
  WindowsOptions get wOptions => WindowsOptions.defaultOptions;

  @override
  WebOptions get webOptions => WebOptions.defaultOptions;

  @override
  MacOsOptions get mOptions => MacOsOptions.defaultOptions;

  @override
  Future<bool?> isCupertinoProtectedDataAvailable() async => false;

  @override
  Stream<bool>? get onCupertinoProtectedDataAvailabilityChanged => null;
}

/// Canned backend responses for the full application flow, matched by
/// HTTP method + path. Requests are recorded for assertions.
FakeHttpClientAdapter buildBackendAdapter(List<RequestOptions> requests) {
  final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
  adapter.onRequest = (RequestOptions options) async {
    requests.add(options);

    final String method = options.method;
    final String path = options.path;

    if (method == 'POST' && path == '/login') {
      final Map<String, dynamic> body = options.data as Map<String, dynamic>;
      return jsonResponse(
        200,
        body['email'] == 'maria@dys.com'
            ? eventManagerLoginJson
            : ownerLoginJson(),
      );
    }
    if (method == 'POST' && path == '/logout') {
      return jsonResponse(200, const <String, dynamic>{});
    }
    if (method == 'GET' && path == '/business-sectors') {
      return jsonResponse(200, {
        'data': businessSectorsJson,
        'message': 'Business sectors retrieved.',
      });
    }
    if (method == 'POST' && path == '/business-sectors/switch') {
      return jsonResponse(200, {
        'data': switchSectorResponseJson,
        'message': 'Sector switched.',
      });
    }
    if (method == 'GET' && path == '/reports') {
      return jsonResponse(200, summaryResponseBody);
    }
    if (method == 'GET' && path == '/sales') {
      return jsonResponse(200, {
        'data': [saleJson, secondSaleJson],
        'message': 'Sales retrieved.',
      });
    }
    if (method == 'POST' && path == '/sales') {
      return jsonResponse(200, {
        'data': saleJson,
        'message': 'Sale recorded successfully.',
      });
    }
    if (method == 'GET' && path == '/expenses') {
      return jsonResponse(200, {
        'data': [expenseJson, payrollExpenseJson],
        'message': 'Expenses retrieved.',
      });
    }
    if (method == 'GET' && path == '/payroll') {
      return jsonResponse(200, {
        'data': [payrollJson, secondPayrollJson],
        'message': 'Payroll records retrieved.',
      });
    }
    if (method == 'GET' && path == '/users') {
      return jsonResponse(200, {
        'data': [ownerUserJson, mariaUserJson, pedroUserJson],
        'message': 'Users retrieved.',
      });
    }
    if (method == 'POST' && path == '/users') {
      return jsonResponse(200, {
        'data': {...mariaUserJson, 'temporary_password': 'Temp@12345'},
        'message': 'User account created successfully.',
      });
    }
    if (method == 'PATCH' && path.startsWith('/users/')) {
      return jsonResponse(200, {
        'data': mariaUserJson,
        'message': 'Account status updated.',
      });
    }

    return jsonResponse(404, {'message': 'Unhandled: $method $path'});
  };
  return adapter;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late SecureStorage secureStorage;
  late List<RequestOptions> requests;

  setUp(() {
    secureStorage = SecureStorage(storage: _InMemoryFlutterSecureStorage());
    requests = <RequestOptions>[];
    ApiClient.init(
      tokenProvider: secureStorage.getToken,
      httpClientAdapter: buildBackendAdapter(requests),
    );
  });

  AuthProvider buildAuthProvider() =>
      AuthProvider(AuthRepository(ApiClient.instance, secureStorage));

  Widget buildApp(AuthProvider authProvider) {
    return App(
      authProvider: authProvider,
      usersProvider: UsersProvider(UsersRepository(ApiClient.instance)),
      dashboardProvider: DashboardProvider(
        DashboardRepository(ApiClient.instance),
      ),
      salesProvider: SalesProvider(SalesRepository(ApiClient.instance)),
      expensesProvider: ExpensesProvider(
        ExpensesRepository(ApiClient.instance),
      ),
      payrollProvider: PayrollProvider(PayrollRepository(ApiClient.instance)),
      reportsProvider: ReportsProvider(ReportsRepository(ApiClient.instance)),
      sectorsProvider: SectorsProvider(SectorsRepository(ApiClient.instance)),
      themeController: ThemeController(ThemeModeStore()),
      router: AppRouter.create(authProvider),
    );
  }

  Future<void> logIn(
    WidgetTester tester, {
    String email = 'owner@dys.com',
  }) async {
    await tester.pumpWidget(buildApp(buildAuthProvider()));
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, email);
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
  }

  testWidgets(
    'owner journey: login, role navigation, record sale, sector switch, '
    'logout',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await logIn(tester);

      expect(find.text('₱150,000.00'), findsOneWidget);
      expect(find.text('DYS Events'), findsOneWidget);

      // Sales tab + record a sale through the real form and POST path.
      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      expect(find.text('Full event coordination package'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '25000.50');
      await tester.enterText(find.byType(TextField).at(1), 'Birthday party');
      await tester.tap(find.text('Save Sale'));
      await tester.pumpAndSettle();
      expect(find.text('Sale recorded successfully.'), findsOneWidget);

      // Expenses tab.
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      expect(find.text('Catering supplies'), findsOneWidget);

      // Payroll tab.
      await tester.tap(find.text('Payroll'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Gomez'), findsOneWidget);

      // Users tab (Business Owner only).
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();
      expect(find.text('Maria Santos'), findsOneWidget);

      // Reports tab (default summary type; generated on demand).
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      expect(find.text('No report yet'), findsOneWidget);

      await tester.tap(find.text('Generate Report'));
      await tester.pumpAndSettle();
      expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
      expect(find.text('₱150,000.00'), findsOneWidget);

      // Switch sector from the dashboard chip; the summary must reload
      // for the new sector (sector_id=2).
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DYS Events'));
      await tester.pumpAndSettle();
      expect(find.text('Switch Business Sector'), findsOneWidget);

      await tester.tap(find.text('B&DYS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch Sector'));
      await tester.pumpAndSettle();

      expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
      expect(find.text('B&DYS'), findsOneWidget);
      final bool summaryRequestedForSectorTwo = requests.any(
        (RequestOptions options) =>
            options.method == 'GET' &&
            options.path == '/reports' &&
            options.queryParameters['type'] == 'summary' &&
            '${options.queryParameters['sector_id']}' == '2',
      );
      expect(summaryRequestedForSectorTwo, isTrue);

      // Logout via the avatar menu returns to the Login screen.
      await tester.tap(find.byType(AppAvatar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Log In'), findsOneWidget);
      expect(await secureStorage.isLoggedIn(), isFalse);
    },
  );

  testWidgets('event manager sees role-scoped navigation and data', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await logIn(tester, email: 'maria@dys.com');

    expect(find.text('Users'), findsNothing);
    expect(find.text('Manage Users'), findsNothing);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('B&DYS'), findsOneWidget);

    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();
    expect(find.text('Full event coordination package'), findsOneWidget);
  });

  testWidgets('session survives an app restart via secure storage', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await logIn(tester);

    // Simulate a fresh app launch: a new provider restores the session
    // from secure storage (token + user data) without re-authenticating.
    final AuthProvider restartedAuth = buildAuthProvider();
    await restartedAuth.checkAuthStatus();

    await tester.pumpWidget(buildApp(restartedAuth));
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsNothing);
    expect(find.text('FINANCIAL SUMMARY'), findsOneWidget);
  });

  testWidgets('login and dashboard render at a mobile viewport size', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await logIn(tester);

    expect(find.text('₱150,000.00'), findsOneWidget);
  });
}

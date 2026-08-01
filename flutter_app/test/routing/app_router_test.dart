import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_users_repository.dart';

const Map<String, dynamic> eventManagerUserJson = {
  'id': 2,
  'name': 'Maria Santos',
  'email': 'maria@dys.com',
  'role': 'Event Manager',
  'sector_id': 2,
  'account_status': 'Active',
};

const Map<String, dynamic> employeeUserJson = {
  'id': 3,
  'name': 'Ana Reyes',
  'email': 'ana@dys.com',
  'role': 'Employee/Staff',
  'sector_id': 1,
  'account_status': 'Active',
};

void main() {
  late FakeAuthRepository fakeRepository;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeRepository = FakeAuthRepository();
  });

  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    bool authenticated = false,
    Map<String, dynamic>? storedUserJson,
  }) async {
    final AuthProvider provider = AuthProvider(fakeRepository);
    if (authenticated) {
      fakeRepository.onIsAuthenticated = () async => true;
      fakeRepository.onGetStoredUser =
          () async => UserModel.fromJson(storedUserJson ?? ownerUserJson);
      await provider.checkAuthStatus();
    }

    final UsersProvider usersProvider =
        UsersProvider(FakeUsersRepository());

    final GoRouter router = AppRouter.create(provider);

    await tester.pumpWidget(App(
      authProvider: provider,
      usersProvider: usersProvider,
      router: router,
    ));
    await tester.pumpAndSettle();

    return router;
  }

  testWidgets('unauthenticated user is shown the login screen',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('unauthenticated user visiting /dashboard is redirected to /login',
      (WidgetTester tester) async {
    final GoRouter router = await pumpApp(tester);

    router.go('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Dashboard — Phase 8'), findsNothing);
  });

  testWidgets('authenticated user visiting /login is redirected to /dashboard',
      (WidgetTester tester) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/login');
    await tester.pumpAndSettle();

    expect(find.text('Dashboard — Phase 8'), findsOneWidget);
    expect(find.text('Log In'), findsNothing);
  });

  testWidgets('owner visiting /users is shown the manage users screen',
      (WidgetTester tester) async {
    final GoRouter router = await pumpApp(tester, authenticated: true);

    router.go('/users');
    await tester.pumpAndSettle();

    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('non-owner visiting /users is redirected to /dashboard',
      (WidgetTester tester) async {
    final GoRouter router =
        await pumpApp(tester, authenticated: true, storedUserJson: eventManagerUserJson);

    router.go('/users');
    await tester.pumpAndSettle();

    expect(find.text('Manage Users'), findsNothing);
    expect(find.text('Dashboard — Phase 8'), findsOneWidget);
  });

  testWidgets('owner bottom nav includes the Users tab',
      (WidgetTester tester) async {
    await pumpApp(tester, authenticated: true);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('tapping the Users tab opens the manage users screen',
      (WidgetTester tester) async {
    await pumpApp(tester, authenticated: true);

    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();

    expect(find.text('USER LIST'), findsOneWidget);
    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('event manager bottom nav hides the Users tab',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('employee bottom nav shows only Dashboard, Payroll, Reports',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Sales'), findsNothing);
    expect(find.text('Expenses'), findsNothing);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('owner dashboard Manage Users quick action navigates to /users',
      (WidgetTester tester) async {
    await pumpApp(tester, authenticated: true);

    expect(find.text('Manage Users'), findsOneWidget);

    await tester.tap(find.text('Manage Users'));
    await tester.pumpAndSettle();

    expect(find.text('USER LIST'), findsOneWidget);
  });

  testWidgets('non-owner dashboard hides the Manage Users quick action',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: eventManagerUserJson,
    );

    expect(find.text('Manage Users'), findsNothing);
  });

  testWidgets('employee dashboard hides the Manage Users quick action',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      authenticated: true,
      storedUserJson: employeeUserJson,
    );

    expect(find.text('Manage Users'), findsNothing);
  });
}

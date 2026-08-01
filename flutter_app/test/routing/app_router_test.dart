import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository fakeRepository;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeRepository = FakeAuthRepository();
  });

  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    bool authenticated = false,
  }) async {
    final AuthProvider provider = AuthProvider(fakeRepository);
    if (authenticated) {
      fakeRepository.onIsAuthenticated = () async => true;
      fakeRepository.onGetStoredUser =
          () async => UserModel.fromJson(ownerUserJson);
      await provider.checkAuthStatus();
    }

    final GoRouter router = AppRouter.create(provider);

    await tester.pumpWidget(App(authProvider: provider, router: router));
    await tester.pumpAndSettle();

    return router;
  }

  testWidgets('unauthenticated user is shown the login screen',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Log In'), findsOneWidget);
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
}

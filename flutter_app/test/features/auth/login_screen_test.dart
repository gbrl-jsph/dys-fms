import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/auth/presentation/screens/login_screen.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_users_repository.dart';

void main() {
  late FakeAuthRepository fakeRepository;
  late AuthProvider provider;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeRepository = FakeAuthRepository();
    provider = AuthProvider(fakeRepository);
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('renders email field, password field, and Log In button',
      (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('empty email shows "Email is required."',
      (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
  });

  testWidgets('empty password shows "Password is required."',
      (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsNothing);
  });

  testWidgets('Log In button shows loading state on tap',
      (WidgetTester tester) async {
    final Completer<LoginResponse> completer = Completer<LoginResponse>();
    fakeRepository.onLogin = (_, _) => completer.future;

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'SecurePass123');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    completer.complete(buildLoginResponse());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('API error displays the error message container',
      (WidgetTester tester) async {
    fakeRepository.onLogin = (_, _) => throw buildUnauthorizedException();

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'wrong');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('successful login navigates to the dashboard',
      (WidgetTester tester) async {
    fakeRepository.onLogin = (_, _) async => buildLoginResponse();

    final GoRouter router = AppRouter.create(provider);
    final UsersProvider usersProvider = UsersProvider(FakeUsersRepository());

    await tester.pumpWidget(App(
      authProvider: provider,
      usersProvider: usersProvider,
      router: router,
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'owner@dys.com');
    await tester.enterText(find.byType(TextField).last, 'SecurePass123');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard — Phase 8'), findsOneWidget);
  });
}

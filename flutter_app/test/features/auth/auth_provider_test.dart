import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/features/auth/data/models/login_response.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/domain/auth_state.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository fakeRepository;
  late AuthProvider provider;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    provider = AuthProvider(fakeRepository);
  });

  test('login() updates state with user and token on success', () async {
    final Completer<LoginResponse> completer = Completer<LoginResponse>();
    fakeRepository.onLogin = (_, _) => completer.future;

    final Future<void> loginFuture =
        provider.login('owner@dys.com', 'SecurePass123');

    expect(provider.state.isLoading, isTrue);

    completer.complete(buildLoginResponse());
    await loginFuture;

    final AuthState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.id, 1);
    expect(state.user?.name, 'Juan Dela Cruz');
    expect(state.user?.email, 'owner@dys.com');
    expect(state.token, '1|test-token');
    expect(state.defaultSector?.id, 1);
    expect(state.defaultSector?.name, 'DYS Events');
  });

  test('login() sets error on failure', () async {
    fakeRepository.onLogin = (_, _) => throw buildUnauthorizedException();

    await provider.login('owner@dys.com', 'wrong');

    final AuthState state = provider.state;
    expect(state.isLoading, isFalse);
    expect(state.isAuthenticated, isFalse);
    expect(state.error, 'Invalid username or password.');
  });

  test('logout() clears state', () async {
    fakeRepository.onLogin = (_, _) async => buildLoginResponse();
    fakeRepository.onLogout = () async {};

    await provider.login('owner@dys.com', 'SecurePass123');
    expect(provider.state.isAuthenticated, isTrue);

    await provider.logout();

    expect(provider.state.isAuthenticated, isFalse);
    expect(provider.state.user, isNull);
    expect(provider.state.token, isNull);
    expect(provider.state.defaultSector, isNull);
  });

  test('checkAuthStatus() detects a stored token', () async {
    fakeRepository.onIsAuthenticated = () async => true;
    fakeRepository.onGetStoredUser =
        () async => UserModel.fromJson(ownerUserJson);

    await provider.checkAuthStatus();

    expect(provider.state.isAuthenticated, isTrue);
    expect(provider.state.user?.email, 'owner@dys.com');
  });

  test('checkAuthStatus() leaves state unauthenticated when no token', () async {
    fakeRepository.onIsAuthenticated = () async => false;

    await provider.checkAuthStatus();

    expect(provider.state.isAuthenticated, isFalse);
    expect(provider.state.user, isNull);
  });
}

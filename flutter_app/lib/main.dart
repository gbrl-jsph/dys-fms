import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/users/data/repositories/users_repository.dart';
import 'features/users/presentation/providers/users_provider.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorage secureStorage = SecureStorage();

  // Wire secure storage as the token provider for the auth interceptor.
  ApiClient.init(tokenProvider: secureStorage.getToken);

  final AuthRepository authRepository =
      AuthRepository(ApiClient.instance, secureStorage);
  final AuthProvider authProvider = AuthProvider(authRepository);

  final UsersRepository usersRepository =
      UsersRepository(ApiClient.instance);
  final UsersProvider usersProvider = UsersProvider(usersRepository);

  // Detect a stored token so the router redirects correctly on startup.
  await authProvider.checkAuthStatus();

  final GoRouter router = AppRouter.create(authProvider);

  runApp(App(
    authProvider: authProvider,
    usersProvider: usersProvider,
    router: router,
  ));
}

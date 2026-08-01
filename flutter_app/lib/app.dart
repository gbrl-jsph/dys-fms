import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

/// Root application widget (blueprint §4.11).
///
/// Provides [AuthProvider] at app level and wires the MaterialApp.router
/// with the theme from [ThemeConfig] and the router from [AppRouter].
class App extends StatelessWidget {
  const App({super.key, required this.authProvider, required this.router});

  final AuthProvider authProvider;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp.router(
        title: 'DYS FMS',
        theme: ThemeConfig.build(),
        routerConfig: router,
      ),
    );
  }
}

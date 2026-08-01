import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';

/// GoRouter configuration (blueprint §4.8).
///
/// Route guarding is driven by [AuthProvider]; `refreshListenable`
/// re-evaluates the redirect whenever auth state changes.
class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.state.isAuthenticated;
        final bool isOnLogin = state.matchedLocation == '/login';

        if (!isAuthenticated) {
          return isOnLogin ? null : '/login';
        }
        if (isOnLogin) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const _RoutePlaceholder(title: 'Login'),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Dashboard — Phase 8'),
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Sales — Phase 3'),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Expenses — Phase 4'),
        ),
        GoRoute(
          path: '/payroll',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Payroll — Phase 5'),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Reports — Phase 6'),
        ),
        GoRoute(
          path: '/sector-switcher',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Sector Switcher — Phase 7'),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) =>
              const _RoutePlaceholder(title: 'Users — Phase 2'),
        ),
      ],
    );
  }
}

/// Minimal placeholder rendered for routes whose screens are not yet
/// implemented (blueprint §4.8 placeholder routes).
class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

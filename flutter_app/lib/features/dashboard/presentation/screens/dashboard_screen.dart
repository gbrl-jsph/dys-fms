import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/section_label.dart';

/// Dashboard placeholder per blueprint §4.10.
///
/// App bar with "Dashboard" title and the user's avatar (initials from
/// [UserModel]). The Business Owner sees the "Manage Users" quick action
/// (navigation-map Rules 5/9, Screen 2 wireframe); the full dashboard
/// (stat cards, chart, remaining quick actions, bottom navigation) arrives
/// in Phase 8.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final String? name = authProvider.state.user?.name;
    final bool isBusinessOwner =
        authProvider.state.user?.isBusinessOwner ?? false;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp1,
            AppSpacing.sp3,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dashboard',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  _Avatar(initials: _initials(name)),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text('Dashboard — Phase 8'),
                ),
              ),
              if (isBusinessOwner) ...[
                const SectionLabel('Quick Actions'),
                const SizedBox(height: AppSpacing.sp2),
                OutlinedButton.icon(
                  onPressed: () => context.go('/users'),
                  icon: const Icon(Icons.group_add_outlined, size: 16),
                  label: const Text('Manage Users'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// User initials from the first letters of the first and last words.
  String _initials(String? name) {
    if (name == null || name.isEmpty) return '';
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// Profile avatar per UI Style Guide (`.avatar-btn`): 36×36, `--r-full`,
/// `--primary-container` background, `--primary-container-ink` initials.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainerInk,
            ),
      ),
    );
  }
}

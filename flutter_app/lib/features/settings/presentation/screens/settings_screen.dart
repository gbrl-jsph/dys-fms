import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/section_label.dart';

/// Settings screen (app-level preferences).
///
/// - Appearance: Light / Dark / System Default radio selection bound to
///   the global [ThemeController]; the choice is persisted on-device and
///   survives app restart and logout / login.
/// - About: application name and version.
///
/// Accessible from the authenticated app UI (Dashboard avatar menu);
/// the router redirects unauthenticated users to the login screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = context.watch<ThemeController>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4,
            AppSpacing.sp2,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          children: [
            AppScreenHeader(
              title: 'Settings',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Appearance'),
            const SizedBox(height: AppSpacing.sp2),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _AppearanceTile(
                    mode: ThemeMode.light,
                    icon: Icons.light_mode_outlined,
                    title: 'Light',
                    subtitle: 'Always use the light theme',
                    currentMode: themeController.mode,
                    onSelected: themeController.setMode,
                  ),
                  Divider(
                    height: 1,
                    indent: AppSpacing.sp4,
                    endIndent: AppSpacing.sp4,
                  ),
                  _AppearanceTile(
                    mode: ThemeMode.dark,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark',
                    subtitle: 'Always use the dark theme',
                    currentMode: themeController.mode,
                    onSelected: themeController.setMode,
                  ),
                  Divider(
                    height: 1,
                    indent: AppSpacing.sp4,
                    endIndent: AppSpacing.sp4,
                  ),
                  _AppearanceTile(
                    mode: ThemeMode.system,
                    icon: Icons.brightness_auto_outlined,
                    title: 'System Default',
                    subtitle: 'Follow the device theme',
                    currentMode: themeController.mode,
                    onSelected: themeController.setMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('About'),
            const SizedBox(height: AppSpacing.sp2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 28,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppInfo.appName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version ${AppInfo.appVersion}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One appearance option row with the radio selection state.
class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.currentMode,
    required this.onSelected,
  });

  final ThemeMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = mode == currentMode;

    return InkWell(
      onTap: () => onSelected(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp4,
          vertical: AppSpacing.sp3,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.inkSecondary),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

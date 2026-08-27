import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_success_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Settings screen (app-level preferences + profile).
///
/// - Profile: current name/email/role/sector, editable name via
///   [AuthProvider.updateProfile] (role/sector are read-only). Both
///   Owner and Staff can edit their own name.
/// - Security: Change Password entry (navigates to /change-password) and
///   Profile entry (navigates to /profile).
/// - Appearance: Light / Dark / System Default radio selection bound to
///   the global [ThemeController]; the choice is persisted on-device and
///   survives app restart and logout / login.
/// - About: application name and version.
///
/// Accessible from the authenticated app UI (Dashboard avatar menu);
/// the router redirects unauthenticated users to the login screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;
  String? _nameError;
  String? _successMessage;

  AuthProvider? _maybeAuth(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  AuthProvider? _maybeWatchAuth(BuildContext context) {
    try {
      return context.watch<AuthProvider>();
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final AuthProvider? auth = _maybeAuth(context);
    final user = auth?.state.user;
    if (user != null) _nameController.text = user.name;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AuthProvider? auth = _maybeWatchAuth(context);
    final user = auth?.state.user;
    if (user != null && !_isEditingName && _nameController.text != user.name) {
      // Keep field in sync when provider updates after save.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isEditingName) {
          _nameController.text = user.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Name is required.';
    if (trimmed.length > 255) return 'Name must not exceed 255 characters.';
    return null;
  }

  Future<void> _saveName() async {
    final String name = _nameController.text.trim();
    final String? error = _validateName(name);
    setState(() {
      _nameError = error;
      _successMessage = null;
    });
    if (error != null) return;

    final provider = _maybeAuth(context);
    if (provider == null) return;
    provider.clearError();
    await provider.updateProfile(name);

    if (!mounted) return;
    if (provider.state.error == null) {
      setState(() {
        _isEditingName = false;
        _successMessage = 'Profile updated successfully.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = context.watch<ThemeController>();
    final AuthProvider? authProvider = _maybeWatchAuth(context);
    final user = authProvider?.state.user;
    final bool isLoading = authProvider?.state.isLoading ?? false;
    final String? serverError = authProvider?.state.error;

    final String sectorName = BusinessSectorsConfig.nameFor(
      user?.sectorId,
      fallback: '—',
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4,
            AppSpacing.sp2,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            AppScreenHeader(
              title: 'Settings',
              onBack: () => context.go('/dashboard'),
            ),
            if (user != null) ...[
              const SizedBox(height: AppSpacing.sp4),
              const SectionLabel('Profile'),
              const SizedBox(height: AppSpacing.sp2),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isEditingName) ...[
                      AppTextField(
                        label: 'Name',
                        controller: _nameController,
                        enabled: !isLoading,
                        hintText: 'Full name',
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                          if (serverError != null) authProvider?.clearError();
                        },
                        onSubmitted: (_) => _saveName(),
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isEditingName = false;
                                        _nameError = null;
                                        _successMessage = null;
                                        _nameController.text =
                                            user.name;
                                      });
                                      authProvider?.clearError();
                                    },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Expanded(
                            child: LoadingButton(
                              label: 'Save',
                              loading: isLoading,
                              onPressed: _saveName,
                            ),
                          ),
                        ],
                      ),
                      if (_successMessage != null) ...[
                        const SizedBox(height: AppSpacing.sp3),
                        AppSuccessContainer(message: _successMessage!),
                      ],
                      if (serverError != null) ...[
                        const SizedBox(height: AppSpacing.sp3),
                        AppErrorContainer(message: serverError),
                      ],
                    ] else ...[
                      _InfoRow(label: 'Name', value: user.name),
                      const SizedBox(height: AppSpacing.sp2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditingName = true;
                              _nameError = null;
                              _successMessage = null;
                              _nameController.text = user.name;
                            });
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Name'),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sp3),
                    _InfoRow(label: 'Email', value: user.email),
                    const SizedBox(height: AppSpacing.sp2),
                    _InfoRow(label: 'Role', value: user.role),
                    const SizedBox(height: AppSpacing.sp2),
                    _InfoRow(label: 'Sector', value: sectorName),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      'Role and sector cannot be changed here.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!_isEditingName && _successMessage != null) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      AppSuccessContainer(message: _successMessage!),
                    ],
                    if (!_isEditingName && serverError != null) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      AppErrorContainer(message: serverError),
                    ],
                    const SizedBox(height: AppSpacing.sp3),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: const Text('View Full Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              const SectionLabel('Security'),
              const SizedBox(height: AppSpacing.sp2),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    Material(
                      color: AppColors.surface,
                      child: ListTile(
                        leading: const Icon(Icons.lock_outline, size: 20),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your password'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push('/change-password'),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: AppSpacing.sp4,
                      endIndent: AppSpacing.sp4,
                    ),
                    Material(
                      color: AppColors.surface,
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, size: 20),
                        title: const Text('Profile'),
                        subtitle:
                            const Text('Manage your personal information'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push('/profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Version ${AppInfo.appVersion}',
                          style: TextStyle(color: AppColors.inkMuted),
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
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.sp2),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
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

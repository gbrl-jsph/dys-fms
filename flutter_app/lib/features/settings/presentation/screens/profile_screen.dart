import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/utils/initials.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_success_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile screen: display current user and allow editing own name.
///
/// Both Owner and Staff can edit their own name. Role and sector are
/// read-only. Calls [AuthProvider.updateProfile] and reflects the updated
/// profile immediately. Accessible to all authenticated users.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  String? _nameError;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final name = context.read<AuthProvider>().state.user?.name;
    if (name != null) _nameController.text = name;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync if provider updates externally (e.g. after save)
    final userName = context.watch<AuthProvider>().state.user?.name;
    if (userName != null && !_isEditing && _nameController.text != userName) {
      _nameController.text = userName;
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

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String? error = _validateName(name);
    setState(() {
      _nameError = error;
      _successMessage = null;
    });
    if (error != null) return;

    final provider = context.read<AuthProvider>();
    provider.clearError();
    await provider.updateProfile(name);

    if (!mounted) return;
    final stateError = provider.state.error;
    if (stateError == null) {
      setState(() {
        _isEditing = false;
        _successMessage = 'Profile updated successfully.';
      });
    } else {
      // Error shown via provider.state.error
      setState(() => _successMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.state.user;
    final bool isLoading = authProvider.state.isLoading;
    final String? serverError = authProvider.state.error;

    final String sectorName = BusinessSectorsConfig.nameFor(
      user?.sectorId,
      fallback: '—',
    );

    // Keep controller synced when not editing
    if (user != null && !_isEditing && _nameController.text != user.name) {
      // Defer to next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isEditing) {
          _nameController.text = user.name;
        }
      });
    }

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
              title: 'Profile',
              onBack: () => context.go('/dashboard'),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Center(
              child: Column(
                children: [
                  AppAvatar(initials: initialsFor(user?.name)),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    user?.name ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Personal Information'),
            const SizedBox(height: AppSpacing.sp2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isEditing) ...[
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
                        if (serverError != null) authProvider.clearError();
                      },
                      onSubmitted: (_) => _save(),
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
                                      _isEditing = false;
                                      _nameError = null;
                                      _successMessage = null;
                                      _nameController.text =
                                          user?.name ?? '';
                                    });
                                    authProvider.clearError();
                                  },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        Expanded(
                          child: LoadingButton(
                            label: 'Save',
                            loading: isLoading,
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _ReadOnlyField(label: 'Name', value: user?.name ?? '—'),
                    const SizedBox(height: AppSpacing.sp3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                            _nameError = null;
                            _successMessage = null;
                          });
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Name'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sp4),
                  _ReadOnlyField(label: 'Email', value: user?.email ?? '—'),
                  const SizedBox(height: AppSpacing.sp4),
                  _ReadOnlyField(label: 'Role', value: user?.role ?? '—'),
                  const SizedBox(height: AppSpacing.sp4),
                  _ReadOnlyField(label: 'Sector', value: sectorName),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'Role and sector cannot be changed here.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_successMessage != null) ...[
                    const SizedBox(height: AppSpacing.sp3),
                    AppSuccessContainer(message: _successMessage!),
                  ],
                  if (serverError != null) ...[
                    const SizedBox(height: AppSpacing.sp3),
                    AppErrorContainer(message: serverError),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            const SectionLabel('Security'),
            const SizedBox(height: AppSpacing.sp2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Manage your password securely.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/change-password'),
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text('Change Password'),
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sp1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3,
            vertical: AppSpacing.sp3,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_success_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Change password screen (authenticated).
///
/// Requires current_password, new_password, new_password_confirmation.
/// Validates current correct, new meets requirements (min 8), confirmation
/// matches, and new is different from current. Calls
/// [AuthProvider.changePassword], handles "Current password is incorrect"
/// and "Passwords do not match", shows success, and requires re-login
/// (the provider clears auth and the router redirects to login).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _succeeded = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final String current = _currentController.text;
    final String newPassword = _newController.text;
    final String confirm = _confirmController.text;

    setState(() {
      _currentError =
          current.isEmpty ? 'Current password is required.' : null;
      _newError = newPassword.isEmpty
          ? 'New password is required.'
          : newPassword.length < 8
              ? 'New password must be at least 8 characters.'
              : newPassword == current
                  ? 'New password must be different from current password.'
                  : null;
      _confirmError = confirm.isEmpty
          ? 'Password confirmation is required.'
          : confirm != newPassword
              ? 'Passwords do not match.'
              : null;
    });

    return _currentError == null &&
        _newError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final AuthProvider provider = context.read<AuthProvider>();
    provider.clearError();
    setState(() => _succeeded = false);

    try {
      await provider.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        newPasswordConfirmation: _confirmController.text,
      );
      if (!mounted) return;
      setState(() => _succeeded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully. Please login again.'),
        ),
      );
      // The provider clears auth and the router will redirect to /login
      // automatically. A small delay allows the snackbar to appear before
      // navigation, but we also push explicitly for non-auto cases.
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        if (context.read<AuthProvider>().state.isAuthenticated) {
          context.go('/login');
        }
      });
    } catch (_) {
      // Error already mapped to provider.state.error
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.state.isLoading;
    final String? serverError = authProvider.state.error;

    // If the password was changed, the provider clears auth and
    // the router redirects to /login. Show a success state until then.
    if (_succeeded && !authProvider.state.isAuthenticated) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: AppColors.success),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  'Password changed successfully. Please login again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sp4),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                title: 'Change Password',
                onBack: () => context.go('/settings'),
              ),
              const SizedBox(height: AppSpacing.sp4),
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
                    AppTextField(
                      label: 'Current Password',
                      controller: _currentController,
                      enabled: !isLoading,
                      obscureText: _obscureCurrent,
                      hintText: 'Enter current password',
                      errorText: _currentError,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureCurrent = !_obscureCurrent,
                        ),
                        tooltip: _obscureCurrent
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      onChanged: (_) {
                        if (_currentError != null) {
                          setState(() => _currentError = null);
                        }
                        if (_newError != null) {
                          setState(() => _newError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      label: 'New Password',
                      controller: _newController,
                      enabled: !isLoading,
                      obscureText: _obscureNew,
                      hintText: 'Enter new password',
                      errorText: _newError,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        tooltip:
                            _obscureNew ? 'Show password' : 'Hide password',
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      onChanged: (_) {
                        if (_newError != null) {
                          setState(() => _newError = null);
                        }
                        if (_confirmError != null) {
                          setState(() => _confirmError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      label: 'Confirm New Password',
                      controller: _confirmController,
                      enabled: !isLoading,
                      obscureText: _obscureConfirm,
                      hintText: 'Confirm new password',
                      errorText: _confirmError,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        tooltip: _obscureConfirm
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      onChanged: (_) {
                        if (_confirmError != null) {
                          setState(() => _confirmError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    LoadingButton(
                      label: 'Change Password',
                      loading: isLoading,
                      onPressed: _submit,
                    ),
                    if (_succeeded) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      const AppSuccessContainer(
                        message:
                            'Password changed successfully. Please login again.',
                      ),
                    ],
                    if (serverError != null) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      AppErrorContainer(message: serverError),
                    ],
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

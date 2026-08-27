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
import '../providers/auth_provider.dart';

/// Reset password screen: email, token, new password, confirmation.
///
/// Uses [AuthProvider.resetPassword] which posts to
/// POST /api/reset-password. Handles "Invalid or expired reset token."
/// and "Passwords do not match" via the error container, and shows
/// success before navigating back to login.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _emailError;
  String? _tokenError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _succeeded = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    final bool valid = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);
    return valid ? null : 'Enter a valid email address.';
  }

  bool _validate() {
    final String email = _emailController.text.trim();
    final String token = _tokenController.text.trim();
    final String password = _passwordController.text;
    final String confirm = _confirmController.text;

    setState(() {
      _emailError = _validateEmail(email);
      _tokenError = token.isEmpty ? 'Reset token is required.' : null;
      _passwordError = password.isEmpty
          ? 'Password is required.'
          : password.length < 8
              ? 'Password must be at least 8 characters.'
              : null;
      _confirmError = confirm.isEmpty
          ? 'Password confirmation is required.'
          : confirm != password
              ? 'Passwords do not match.'
              : null;
    });

    return _emailError == null &&
        _tokenError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final AuthProvider provider = context.read<AuthProvider>();
    provider.clearError();
    setState(() => _succeeded = false);

    try {
      await provider.resetPassword(
        email: _emailController.text.trim(),
        token: _tokenController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );
      if (!mounted) return;
      setState(() => _succeeded = true);
    } catch (_) {
      // Error shown via provider.state.error
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.state.isLoading;
    final String? serverError = authProvider.state.error;

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
                title: 'Reset Password',
                onBack: () => context.go('/login'),
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
                      label: 'Email',
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      hintText: 'Enter email',
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      label: 'Reset Token',
                      controller: _tokenController,
                      enabled: !isLoading,
                      hintText: 'Enter reset token',
                      errorText: _tokenError,
                      onChanged: (_) {
                        if (_tokenError != null) {
                          setState(() => _tokenError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      label: 'New Password',
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      hintText: 'Enter new password',
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                        if (_confirmError != null) {
                          setState(() => _confirmError = null);
                        }
                        if (serverError != null) authProvider.clearError();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AppTextField(
                      label: 'Confirm Password',
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
                      label: 'Reset Password',
                      loading: isLoading,
                      onPressed: _submit,
                    ),
                    if (_succeeded) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      const AppSuccessContainer(
                        message:
                            'Password has been reset successfully. Please login.',
                      ),
                    ],
                    if (serverError != null) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      AppErrorContainer(message: serverError),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              if (_succeeded)
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'),
                )
              else
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text('Resend Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

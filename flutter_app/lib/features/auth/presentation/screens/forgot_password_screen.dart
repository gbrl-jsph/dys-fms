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

/// Forgot password screen: email input to request a reset link.
///
/// Uses [AuthProvider.forgotPassword] which posts to
/// POST /api/forgot-password. The backend always returns a generic success
/// message to prevent account enumeration, so this screen shows that
/// generic success even when the email does not exist.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _succeeded = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    final bool valid = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);
    return valid ? null : 'Enter a valid email address.';
  }

  Future<void> _submit() async {
    final String email = _emailController.text.trim();
    final String? emailError = _validateEmail(email);

    setState(() {
      _emailError = emailError;
    });

    if (emailError != null) return;

    final AuthProvider provider = context.read<AuthProvider>();
    provider.clearError();
    setState(() => _succeeded = false);

    try {
      await provider.forgotPassword(email);
      if (!mounted) return;
      setState(() => _succeeded = true);
    } catch (_) {
      // Error is exposed via provider.state.error and shown inline.
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
                title: 'Forgot Password',
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
                    Text(
                      'Enter your email address and we will send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
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
                        if (serverError != null) {
                          authProvider.clearError();
                        }
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    LoadingButton(
                      label: 'Send Reset Link',
                      loading: isLoading,
                      onPressed: _submit,
                    ),
                    if (_succeeded) ...[
                      const SizedBox(height: AppSpacing.sp3),
                      const AppSuccessContainer(
                        message:
                            'If an account exists with that email, a password reset link has been sent.',
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
              TextButton(
                onPressed: () => context.go('/reset-password'),
                child: const Text('Have a reset token? Reset Password'),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

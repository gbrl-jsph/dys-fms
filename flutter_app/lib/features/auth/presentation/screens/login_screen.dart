import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/auth_provider.dart';

/// Login screen per UI Style Guide (Screen 1) and blueprint §4.9.
///
/// Email + password fields with Show/Hide password toggle, inline
/// validation (email required, valid format, password required), a
/// loading state on the Log In button, and the inline server error
/// container. Navigation after successful login is handled by the
/// GoRouter redirect (see AppRouter): once [AuthProvider] flips
/// `isAuthenticated`, `/login` automatically redirects to `/dashboard`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    final String? emailError = _validateEmail(email);
    final String? passwordError = password.isEmpty
        ? 'Password is required.'
        : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError == null && passwordError == null) {
      context.read<AuthProvider>().login(email, password);
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    final bool valid = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);
    return valid ? null : 'Enter a valid email address.';
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.state.isLoading;
    final String? serverError = authProvider.state.error;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _LoginHero(),
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
                },
              ),
              const SizedBox(height: AppSpacing.sp4),
              AppTextField(
                label: 'Password',
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Enter password',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
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
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.sp4),
              LoadingButton(
                label: 'Log In',
                loading: isLoading,
                onPressed: _submit,
              ),
              if (serverError != null) ...[
                const SizedBox(height: AppSpacing.sp4),
                AppErrorContainer(message: serverError, centered: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// DYS logo mark + title + subtitle hero (wireframe `.login-hero`).
class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sp6,
        bottom: AppSpacing.sp5,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.shadowCta,
            ),
            child: Text(
              'DYS',
              style: textTheme.displaySmall?.copyWith(
                color: AppColors.inkOnPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            'DYS Financial Management System (DYS FMS)',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Management System',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

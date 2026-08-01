import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme.dart';
import '../providers/auth_provider.dart';

/// Login screen per UI Style Guide (Screen 1) and blueprint §4.9.
///
/// Navigation after successful login is handled by the GoRouter
/// redirect (see AppRouter): once [AuthProvider] flips
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
    final String? passwordError =
        password.isEmpty ? 'Password is required.' : null;

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
    final bool valid =
        RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);
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
              const _FieldLabel('Email'),
              TextField(
                controller: _emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(hintText: 'Enter email'),
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              if (_emailError != null)
                _ErrorContainer(message: _emailError!),
              const SizedBox(height: AppSpacing.sp4),
              const _FieldLabel('Password'),
              TextField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(hintText: 'Enter password'),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              if (_passwordError != null)
                _ErrorContainer(message: _passwordError!),
              const SizedBox(height: AppSpacing.sp4),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.inkOnPrimary,
                        ),
                      )
                    : const Text('Log In'),
              ),
              if (serverError != null) ...[
                const SizedBox(height: AppSpacing.sp4),
                _ErrorContainer(message: serverError, centered: true),
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
      padding:
          const EdgeInsets.only(top: AppSpacing.sp6, bottom: AppSpacing.sp5),
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
              style: textTheme.displaySmall
                  ?.copyWith(color: AppColors.inkOnPrimary),
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
            style: textTheme.bodyLarge
                ?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

/// Form field label (wireframe `.field-label`).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

/// Validation / error message container per UI Style Guide:
/// `--danger-container` background, warning icon + `--danger` text.
class _ErrorContainer extends StatelessWidget {
  const _ErrorContainer({required this.message, this.centered = false});

  final String message;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sp1),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp3,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.dangerContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              size: 14,
              color: AppColors.danger,
            ),
            const SizedBox(width: AppSpacing.sp2),
            Flexible(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

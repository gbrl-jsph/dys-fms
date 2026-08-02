import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Full-width primary button with a built-in loading state.
///
/// Per the UI Style Guide loading spec: while [loading] is true the
/// button is disabled and the label is replaced by a spinner.
/// Styling comes entirely from the [AppTheme] `ElevatedButtonTheme`
/// (primary variant, `--shadow-cta`, 48px height, 12px radius).
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.inkOnPrimary,
              ),
            )
          : Text(label),
    );
  }
}

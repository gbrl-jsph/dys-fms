import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

/// Inline success feedback container (UI Style Guide:
/// `--success-container` background, check icon + `--success` text,
/// 10px/12px padding, 12px radius).
///
/// [temporaryPassword] appends the one-time password displayed by the
/// User Account Management screen after account creation.
class AppSuccessContainer extends StatelessWidget {
  const AppSuccessContainer({
    super.key,
    required this.message,
    this.temporaryPassword,
  });

  final String message;
  final String? temporaryPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp3,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sp2),
          Flexible(
            child: Text(
              temporaryPassword == null
                  ? message
                  : '$message Temporary password: $temporaryPassword',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

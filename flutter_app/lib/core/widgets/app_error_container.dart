import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

/// Validation / error message container per UI Style Guide:
/// `--danger-container` background, warning icon + `--danger` text,
/// 10px/12px padding, 12px radius.
class AppErrorContainer extends StatelessWidget {
  const AppErrorContainer({
    super.key,
    required this.message,
    this.centered = false,
  });

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
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 14, color: AppColors.danger),
            const SizedBox(width: AppSpacing.sp2),
            Flexible(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

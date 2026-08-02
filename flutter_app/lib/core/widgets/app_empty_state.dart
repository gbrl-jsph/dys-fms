import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Empty state placeholder (UI Style Guide: Empty States).
///
/// Muted icon + title + optional message, used for "No records yet"
/// table bodies and chart placeholder areas.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.inkMuted.withValues(alpha: 0.55),
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sp1),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

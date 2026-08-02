import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Profile avatar per UI Style Guide (`.avatar-btn`): 36×36, `--r-full`,
/// `--primary-container` background, `--primary-container-ink` initials
/// (13px, 700 weight). Used in the Dashboard and Users app bars.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18, // 36×36 diameter (--r-full)
      backgroundColor: AppColors.primaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryContainerInk,
        ),
      ),
    );
  }
}

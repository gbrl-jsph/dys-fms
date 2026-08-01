import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Uppercase section label (wireframe `.section-label`).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
            letterSpacing: AppTypography.letterSpacingSectionLabel,
          ),
    );
  }
}

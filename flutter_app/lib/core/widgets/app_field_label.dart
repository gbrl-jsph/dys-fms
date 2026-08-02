import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// Form field label (wireframe `.field-label`): 12.5px/600,
/// `--ink-secondary`, 8px bottom margin.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

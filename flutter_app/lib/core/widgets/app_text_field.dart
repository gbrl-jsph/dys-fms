import 'package:flutter/material.dart';

import 'app_error_container.dart';
import 'app_field_label.dart';

/// Reusable text field (wireframe `.field-input` / `.field-select`).
///
/// Renders the 12.5px/600 field label above the input and, when
/// [errorText] is set, the UI Style Guide validation message container.
/// Visual styling comes from the global `InputDecorationTheme`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final bool enabled;

  /// Disables editing; [onTap] still fires (used for picker fields).
  final bool readOnly;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldLabel(label),
        TextField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          autocorrect: autocorrect,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
        ),
        if (errorText != null) AppErrorContainer(message: errorText!),
      ],
    );
  }
}

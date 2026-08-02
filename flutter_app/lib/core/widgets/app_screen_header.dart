import 'package:flutter/material.dart';

/// Screen header per the wireframes: back button to Dashboard +
/// centered [title] (navigation-map Rule 3).
///
/// Used by the operational screens (Sales, Expenses, Payroll, Reports,
/// Sector Switcher) and the Users screen header pattern.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Back to Dashboard',
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

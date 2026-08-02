import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/widgets/loading_button.dart';

void main() {
  testWidgets('renders the label and is enabled by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(label: 'Save', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('shows a spinner and disables the button while loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingButton(label: 'Save', loading: true, onPressed: null),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });

  testWidgets('invokes onPressed when tapped', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(label: 'Save', onPressed: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('Save'));

    expect(tapped, isTrue);
  });
}

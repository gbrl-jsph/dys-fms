import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/core/widgets/app_chart_placeholder.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 240, child: child),
      ),
    ),
  );

  testWidgets('renders the placeholder without painting errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppChartPlaceholder()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Graph placeholder'), findsOneWidget);
    expect(
      find.text('Bar / line chart · populates once transactions are recorded'),
      findsOneWidget,
    );
  });

  testWidgets('honors custom title, subtitle, and height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppChartPlaceholder(
          title: 'Monthly Sales',
          subtitle: 'Populates after first sale',
          height: 100,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Monthly Sales'), findsOneWidget);
    expect(find.text('Populates after first sale'), findsOneWidget);
    expect(tester.getSize(find.byType(AppChartPlaceholder)).height, 100);
  });

  testWidgets('renders with a narrow width without painting errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 120, child: const AppChartPlaceholder()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppChartPlaceholder), findsOneWidget);
  });
}

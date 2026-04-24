import 'package:ephimeries/widgets/chart/north_indian_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';

void main() {
  testWidgets('NorthIndianChart lays out with no overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: NorthIndianChart(data: buildTestChart()),
            ),
          ),
        ),
      ),
    );

    // Didn't throw, didn't overflow
    expect(tester.takeException(), isNull);
    expect(find.byType(NorthIndianChart), findsOneWidget);
  });
}

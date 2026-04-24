import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/widgets/chart/south_indian_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';

void main() {
  testWidgets('SouthIndianChart renders without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: SouthIndianChart(data: buildTestChart()),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SouthIndianChart), findsOneWidget);
  });

  test('signCells covers all 12 zodiac signs with distinct (row, col) pairs',
      () {
    expect(SouthIndianChart.signCells.length, 12);
    final cells = SouthIndianChart.signCells.values.toSet();
    expect(cells.length, 12, reason: 'each sign must live in a distinct cell');

    for (final ZodiacSign s in ZodiacSign.values) {
      expect(SouthIndianChart.signCells.containsKey(s), isTrue,
          reason: 'missing sign $s');
    }

    // No sign should occupy the 2x2 centre block.
    for (final (row, col) in cells) {
      final inCentre =
          (row == 1 || row == 2) && (col == 1 || col == 2);
      expect(inCentre, isFalse,
          reason: 'sign must not occupy centre cell ($row,$col)');
    }
  });
}

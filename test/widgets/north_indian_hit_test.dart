// Geometric sanity check: every cell should hit-test to a unique house and
// cover the centre/corners correctly. We don't import the private layout
// directly — instead we paint the chart, then tap at known positions and
// assert the bottom sheet opens with the correct house number in its title.

import 'package:ephimeries/widgets/chart/north_indian_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';
import 'test_harness.dart';

void main() {
  testWidgets('tapping top-center opens house 1 sheet', (tester) async {
    const size = 400.0;
    await tester.pumpWidget(
      harnessedSized(
        NorthIndianChart(data: buildTestChart()),
        width: size,
        height: size,
      ),
    );

    // Tap just inside the top-center cell (house 1) — roughly y = 0.15 * size.
    final chartFinder = find.byType(NorthIndianChart);
    final topLeft = tester.getTopLeft(chartFinder);
    await tester.tapAt(Offset(topLeft.dx + size / 2, topLeft.dy + size * 0.15));
    await tester.pumpAndSettle();

    // Detail sheet title should contain "House 1"
    expect(find.textContaining('House 1'), findsOneWidget);
  });
}

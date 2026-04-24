import 'package:ephimeries/widgets/chart/quick_stats_row.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';
import 'test_harness.dart';

void main() {
  testWidgets('QuickStatsRow shows Lagna, Moon, Sun, Nakshatra', (tester) async {
    await tester.pumpWidget(
      harnessed(QuickStatsRow(chart: buildTestChart())),
    );
    await tester.pumpAndSettle();

    // Labels
    expect(find.text('Lagna:'), findsOneWidget);
    expect(find.text('Moon:'), findsOneWidget);
    expect(find.text('Sun:'), findsOneWidget);
    expect(find.text('Nakshatra:'), findsOneWidget);

    // Values from fixture: asc=Aries, Moon in Cancer, Sun in Taurus, Nakshatra=rohini
    expect(find.text('Mesha'), findsOneWidget); // Aries
    expect(find.text('Karka'), findsOneWidget); // Cancer
    expect(find.text('Vrishabha'), findsOneWidget); // Taurus
    expect(find.text('rohini'), findsOneWidget);
  });
}

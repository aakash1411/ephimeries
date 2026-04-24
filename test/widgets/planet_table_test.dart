import 'package:ephimeries/widgets/chart/planet_table.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';
import 'test_harness.dart';

void main() {
  testWidgets('PlanetDetailTable lists all 9 grahas and retrograde marks',
      (tester) async {
    await tester.pumpWidget(
      harnessed(PlanetDetailTable(chart: buildTestChart())),
    );
    await tester.pumpAndSettle();

    // Each planet appears once in a row.
    expect(find.text('Surya'), findsOneWidget);
    expect(find.text('Chandra'), findsOneWidget);
    expect(find.text('Mangala'), findsOneWidget);
    expect(find.text('Budha'), findsOneWidget);
    expect(find.text('Guru'), findsOneWidget);
    expect(find.text('Shukra'), findsOneWidget);
    expect(find.text('Shani'), findsOneWidget);
    expect(find.text('Rahu'), findsOneWidget);
    expect(find.text('Ketu'), findsOneWidget);

    // Mars + Saturn are retrograde in the fixture → 2 "R" cells.
    // Plus one more "R" for the column header → total 3.
    expect(find.text('R'), findsNWidgets(3));
    // Non-retrograde rows render "—".
    expect(find.text('—'), findsNWidgets(7));
  });
}

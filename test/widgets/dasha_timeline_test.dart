import 'package:ephimeries/widgets/chart/dasha_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';

void main() {
  testWidgets('DashaTimelineWidget shows current Maha + Antar', (tester) async {
    final dasha = buildTestDasha();
    // Pretend "now" is 2 months after birth → Moon maha + Mars antar active.
    final now = dasha.mahaDasha.startDate.add(const Duration(days: 60));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashaTimelineWidget(
            dasha: dasha,
            now: now,
            birthDate: dasha.mahaDasha.startDate,
            timezoneName: 'UTC',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Summary card: "Chandra  ·  Mangala"
    expect(find.textContaining('Chandra'), findsWidgets);
    expect(find.textContaining('Mangala'), findsWidgets);
  });
}

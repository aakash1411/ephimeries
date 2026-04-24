import 'package:ephimeries/widgets/common/chart_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChartSkeleton renders without overflow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 300, height: 300, child: ChartSkeleton()),
          ),
        ),
      ),
    );
    // Shimmer uses its own animation controller; pump once to let it settle.
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(ChartSkeleton), findsOneWidget);
  });
}

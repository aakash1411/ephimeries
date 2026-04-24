import 'package:ephimeries/domain/models/app_settings.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/providers/settings_provider.dart';
import 'package:ephimeries/widgets/chart/planet_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_fixtures.dart';

/// BUG-4 regression — `AppSettings.showRetrograde = false` must hide the "R"
/// marker in the planet table.
void main() {
  testWidgets('R column hidden when showRetrograde is false', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            () => _SettingsStub(showRetrograde: false),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: PlanetDetailTable(chart: buildTestChart())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fixture has 2 retrograde planets. With showRetrograde=false, no data
    // cell shows 'R' — only the column header. All 9 rows show the em-dash.
    expect(find.text('R'), findsOneWidget); // header only
    expect(find.text('—'), findsNWidgets(9));
  });

  testWidgets('R column visible when showRetrograde is true', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            () => _SettingsStub(showRetrograde: true),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: PlanetDetailTable(chart: buildTestChart())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fixture: 2 retrograde planets (Mars, Saturn) → 2 'R' cells + 1 header.
    expect(find.text('R'), findsNWidgets(3));
  });
}

class _SettingsStub extends SettingsNotifier {
  _SettingsStub({required this.showRetrograde});
  final bool showRetrograde;

  @override
  AppSettings build() => AppSettings(
        nameLanguage: NameLanguage.sanskrit,
        degreeFormat: DegreeFormat.dms,
        showRetrograde: showRetrograde,
      );
}

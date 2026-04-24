import 'package:ephimeries/domain/models/dasha_data.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// RCA-5 regression — `DashaData.activeAt` must return the period that
/// contains the query instant, independent of when the DashaData was fetched.
void main() {
  DashaPeriod p(
    PlanetType planet,
    DateTime start,
    DateTime end, {
    List<DashaPeriod> subPeriods = const [],
    int level = 1,
  }) =>
      DashaPeriod(
        planet: planet,
        startDate: start,
        endDate: end,
        level: level,
        subPeriods: subPeriods,
      );

  final moon = p(
    PlanetType.moon,
    DateTime.utc(2020, 1, 1),
    DateTime.utc(2030, 1, 1),
    subPeriods: [
      p(
        PlanetType.moon,
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2024, 12, 31, 12),
        level: 2,
      ),
      p(
        PlanetType.mars,
        DateTime.utc(2024, 12, 31, 12),
        DateTime.utc(2027, 1, 1),
        level: 2,
      ),
    ],
  );
  final mars = p(
    PlanetType.mars,
    DateTime.utc(2030, 1, 1),
    DateTime.utc(2037, 1, 1),
    subPeriods: [
      p(
        PlanetType.mars,
        DateTime.utc(2030, 1, 1),
        DateTime.utc(2031, 1, 1),
        level: 2,
      ),
    ],
  );

  final dasha = DashaData(
    mahaDasha: moon,
    antarDasha: moon.subPeriods.first,
    current: moon.subPeriods.first,
    mahaSequence: [moon, mars],
  );

  test('activeAt: before the maha transition picks Moon', () {
    final a = dasha.activeAt(DateTime.utc(2024, 1, 1));
    expect(a.maha.planet, PlanetType.moon);
    expect(a.antar.planet, PlanetType.moon);
  });

  test(
      'activeAt: one minute AFTER the antar rollover picks the new antar — '
      'even though compute-time snapshot still points at Moon', () {
    final a = dasha.activeAt(DateTime.utc(2024, 12, 31, 12, 1));
    expect(a.maha.planet, PlanetType.moon);
    expect(a.antar.planet, PlanetType.mars);
  });

  test('activeAt: after the maha rollover picks the new maha', () {
    final a = dasha.activeAt(DateTime.utc(2031, 6, 1));
    expect(a.maha.planet, PlanetType.mars);
    expect(a.antar.planet, PlanetType.mars);
  });

  test('activeAt: outside the computed window falls back to the snapshot', () {
    final a = dasha.activeAt(DateTime.utc(2100, 1, 1));
    expect(a.maha.planet, PlanetType.moon); // falls back to dasha.mahaDasha
  });
}

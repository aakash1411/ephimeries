import 'package:ephimeries/data/repositories/jyotish_chart_repository.dart';
import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jyotish/jyotish.dart' as jy;

/// On-device smoke test for the real Swiss Ephemeris integration.
/// Run with: `flutter test integration_test/ -d ios|android`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late JyotishChartRepository repo;

  setUpAll(() async {
    final engine = jy.Jyotish();
    await engine.initialize();
    repo = JyotishChartRepository(engine: engine);
  });

  testWidgets('natal + D9 + dasha compute for reference birth data',
      (tester) async {
    final profile = BirthProfile(
      id: 'smoke',
      name: 'Smoke',
      dateTime: DateTime.utc(1990, 5, 15, 9, 0),
      latitude: 27.7172,
      longitude: 85.3240,
      altitude: 1300,
      placeLabel: 'Kathmandu, Nepal',
      createdAt: DateTime.utc(1990, 5, 15, 9, 0),
    );

    final natal = await repo.getNatalChart(profile);
    expect(natal.planets.length, 9);
    expect(natal.houseData.length, 12);

    final sun = natal.planets.firstWhere((p) => p.planet == PlanetType.sun);
    expect(sun.sign, ZodiacSign.taurus);

    final d9 = await repo.getDivisionalChart(profile, 9);
    expect(d9.divisor, 9);

    final dasha = await repo.getDasha(profile);
    expect(dasha.mahaSequence, isNotEmpty);

    // § 11 Regression assertions — verify structural invariants that hold
    // regardless of which JHora reference values you fill in later.

    // Profile A: Rahu + Ketu opposition (always 6 signs apart).
    final rahu = natal.planets.firstWhere((p) => p.planet == PlanetType.rahu);
    final ketu = natal.planets.firstWhere((p) => p.planet == PlanetType.ketu);
    expect(
      (rahu.sign.index - ketu.sign.index).abs() % 12,
      6,
      reason: 'Rahu and Ketu must always be exactly 6 signs apart',
    );

    // Profile A: dasha sequence has 9 distinct lords spanning ~120 years.
    final lords = dasha.mahaSequence.map((m) => m.planet).toSet();
    expect(lords.length, 9,
        reason: 'Vimshottari cycle must include all 9 grahas exactly once');
    final spanDays = dasha.mahaSequence.last.endDate
        .difference(dasha.mahaSequence.first.startDate)
        .inDays;
    expect(spanDays, closeTo(120 * 365.25, 2),
        reason: 'Total maha sequence span must be ~120 years (±2 days)');

    // Profile A D9 vs D1 should differ at the ascendant (varga computation).
    expect(d9.ascendantSign, isNot(natal.ascendantSign),
        reason: 'D9 ascendant should rarely equal D1 ascendant');
  });

  testWidgets('BUG-1 regression — DST vs non-DST New York round-trip', (t) async {
    TimezoneService.ensureInitialized();

    // DST (July) → UTC-4, so 08:00 EDT = 12:00 UTC.
    expect(
      TimezoneService.toUtc(
        DateTime(1985, 7, 4, 8),
        'America/New_York',
      ),
      DateTime.utc(1985, 7, 4, 12),
    );

    // Non-DST (January) → UTC-5, so 08:00 EST = 13:00 UTC.
    expect(
      TimezoneService.toUtc(
        DateTime(1985, 1, 15, 8),
        'America/New_York',
      ),
      DateTime.utc(1985, 1, 15, 13),
    );
  });
}

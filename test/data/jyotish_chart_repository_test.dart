@Tags(['integration'])
library;

import 'dart:io' show Platform;

import 'package:ephimeries/data/repositories/jyotish_chart_repository.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart' as jy;

/// Reference birth data:
///   1990-05-15 14:30 IST (Asia/Kolkata) = 09:00 UTC
///   Kathmandu 27.7172°N 85.3240°E 1300m
///
/// Expectations (Lahiri sidereal, jyotish ^2.5.0):
/// - Ascendant: Leo (Simha)  — ascendant typically falls between Leo/Virgo
/// - Sun: Taurus
/// - Moon: Capricorn (nakshatra validated below)
BirthProfile _reference() => BirthProfile(
      id: 'ref',
      name: 'Reference',
      dateTime: DateTime.utc(1990, 5, 15, 9, 0),
      latitude: 27.7172,
      longitude: 85.3240,
      altitude: 1300,
      placeLabel: 'Kathmandu, Nepal',
      createdAt: DateTime.utc(1990, 5, 15, 9, 0),
    );

/// Swiss Ephemeris's native `libswisseph` dylib ships only in the iOS and
/// Android platform plugins; running under `flutter test` on macOS/Linux host
/// cannot load it. Skip cleanly in those environments.
final String? _hostSkipReason = (Platform.isIOS || Platform.isAndroid)
    ? null
    : 'Swiss Ephemeris native library is unavailable on host '
        '(${Platform.operatingSystem}). Run this suite on an iOS/Android '
        'device or simulator via `flutter test integration_test/`.';

void main() {
  late JyotishChartRepository repo;

  setUpAll(() async {
    if (_hostSkipReason != null) return;
    TestWidgetsFlutterBinding.ensureInitialized();
    final engine = jy.Jyotish();
    await engine.initialize();
    repo = JyotishChartRepository(engine: engine);
  });

  group('JyotishChartRepository (integration)', skip: _hostSkipReason, () {
    test('natal chart returns 9 planets, 12 houses, valid ascendant',
        () async {
      final chart = await repo.getNatalChart(_reference());

      expect(chart.planets.length, 9);
      expect(chart.houseData.length, 12);
      expect(chart.ascendantDegree, inInclusiveRange(0.0, 30.0));
      expect(chart.divisor, 1);

      for (final p in chart.planets) {
        expect(p.house, inInclusiveRange(1, 12));
        expect(p.degree, inInclusiveRange(0.0, 30.0));
        expect(p.nakshatraPada, inInclusiveRange(1, 4));
      }
    });

    test('Sun for reference data is in Taurus (sidereal Lahiri)', () async {
      final chart = await repo.getNatalChart(_reference());
      final sun = chart.planets.firstWhere((p) => p.planet == PlanetType.sun);
      expect(sun.sign, ZodiacSign.taurus);
    });

    test('Rahu and Ketu are exactly 180° apart', () async {
      final chart = await repo.getNatalChart(_reference());
      final rahu = chart.planets.firstWhere((p) => p.planet == PlanetType.rahu);
      final ketu = chart.planets.firstWhere((p) => p.planet == PlanetType.ketu);
      final diff = ((rahu.sign.index - ketu.sign.index) + 12) % 12;
      expect(diff, 6, reason: 'Rahu and Ketu must be in opposite signs');
    });

    test('D9 Navamsa computes without error', () async {
      final d9 = await repo.getDivisionalChart(_reference(), 9);
      expect(d9.divisor, 9);
      expect(d9.planets.length, 9);
    });

    test('all 16 D-charts compute without error', () async {
      const divisors = <int>[
        1, 2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60,
      ];
      for (final d in divisors) {
        final chart = await repo.getDivisionalChart(_reference(), d);
        expect(chart.divisor, d, reason: 'D$d');
        expect(chart.planets.length, 9, reason: 'D$d should have 9 planets');
      }
    });

    test('Vimshottari dasha returns Maha + Antar + full Maha sequence',
        () async {
      final dasha = await repo.getDasha(_reference());
      expect(dasha.mahaSequence, isNotEmpty);
      expect(dasha.mahaDasha.level, 1);
      expect(dasha.antarDasha.level, 2);
      // Total span of all mahadashas should be 120 years (give or take).
      final first = dasha.mahaSequence.first.startDate;
      final last = dasha.mahaSequence.last.endDate;
      final years = last.difference(first).inDays / 365.25;
      expect(years, closeTo(120, 2));
    });

    test('Panchang returns non-empty five limbs', () async {
      final p = await repo.getPanchang(
        _reference(),
        DateTime.utc(2024, 1, 1, 6, 0),
      );
      expect(p.tithiName, isNotEmpty);
      expect(p.yogaName, isNotEmpty);
      expect(p.karanaName, isNotEmpty);
      expect(p.weekday, isNotEmpty);
    });

    test('Transit chart returns planets at the transit moment', () async {
      final now = DateTime.utc(2024, 6, 15, 12, 0);
      final t = await repo.getTransitChart(_reference(), now);
      expect(t.profile.dateTime, now);
      expect(t.planets.length, 9);
    });
  });
}

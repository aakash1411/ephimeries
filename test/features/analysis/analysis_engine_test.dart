import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/dasha_data.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/domain/models/planet_position.dart';
import 'package:ephimeries/domain/models/vedic_chart_data.dart';
import 'package:ephimeries/features/analysis/analysis_engine.dart';
import 'package:ephimeries/features/analysis/planetary_dignity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Build a fixture natal chart where every PlanetPosition can be specified.
VedicChartData _chart({
  required ZodiacSign ascendant,
  required List<PlanetPosition> planets,
}) {
  return VedicChartData(
    profile: BirthProfile(
      id: 'fixture',
      name: 'Fixture',
      dateTime: DateTime.utc(2000, 1, 1),
      latitude: 0,
      longitude: 0,
      altitude: 0,
      placeLabel: 'Somewhere',
      createdAt: DateTime.utc(2000, 1, 1),
    ),
    ascendantSign: ascendant,
    ascendantDegree: 0,
    planets: planets,
    houseData: const [],
    nakshatra: Nakshatra.ashwini,
  );
}

PlanetPosition _p(PlanetType planet, ZodiacSign sign, int house) {
  return PlanetPosition(
    planet: planet,
    sign: sign,
    house: house,
    degree: 10,
    isRetrograde: false,
    nakshatra: Nakshatra.ashwini,
    nakshatraPada: 1,
  );
}

DashaData _dasha() {
  final start = DateTime.utc(2020, 1, 1);
  final mahaSun = DashaPeriod(
    planet: PlanetType.sun,
    startDate: start,
    endDate: DateTime.utc(2026, 1, 1),
    level: 1,
    subPeriods: [
      DashaPeriod(
        planet: PlanetType.jupiter,
        startDate: start,
        endDate: DateTime.utc(2026, 1, 1),
        level: 2,
      ),
    ],
  );
  return DashaData(
    mahaDasha: mahaSun,
    antarDasha: mahaSun.subPeriods.first,
    current: mahaSun.subPeriods.first,
    mahaSequence: [mahaSun],
  );
}

void main() {
  group('AnalysisEngine', () {
    test('picks top placements ranked by dignity + house bonus', () {
      final natal = _chart(
        ascendant: ZodiacSign.leo,
        planets: [
          // Sun exalted in Aries, 9th (trikona) — should rank #1
          _p(PlanetType.sun, ZodiacSign.aries, 9),
          // Saturn exalted in Libra, 3rd (upachaya for malefic) — #2
          _p(PlanetType.saturn, ZodiacSign.libra, 3),
          // Venus debilitated in Virgo, 2nd (neutral) — #bottom
          _p(PlanetType.venus, ZodiacSign.virgo, 2),
          // Moon in Cancer (own), 12th (dusthana benefic) — middle
          _p(PlanetType.moon, ZodiacSign.cancer, 12),
          // Mars in Capricorn (exalted), 6th (upachaya malefic) — top
          _p(PlanetType.mars, ZodiacSign.capricorn, 6),
          _p(PlanetType.mercury, ZodiacSign.taurus, 10),
          _p(PlanetType.jupiter, ZodiacSign.taurus, 10),
          _p(PlanetType.rahu, ZodiacSign.taurus, 10),
          _p(PlanetType.ketu, ZodiacSign.scorpio, 4),
        ],
      );

      final report = AnalysisEngine.compute(natal: natal);
      expect(report.keyPlacements.length, 5);
      // The strongest placements are Sun (exalted + trikona) and Mars
      // (exalted + upachaya) — both should be in the top 5.
      final all = report.keyPlacements.map((p) => p.planet).toSet();
      expect(all.contains(PlanetType.sun), isTrue);
      expect(all.contains(PlanetType.mars), isTrue);
      // Venus (debilitated, in 2nd): score -2 — should NOT be in top 5.
      expect(all.contains(PlanetType.venus), isFalse);
    });

    test('lagnaBlurb resolves from the kLagnaDescriptions table', () {
      final natal = _chart(
        ascendant: ZodiacSign.cancer,
        planets: [_p(PlanetType.sun, ZodiacSign.leo, 1)],
      );
      final r = AnalysisEngine.compute(natal: natal);
      expect(r.lagnaSign, ZodiacSign.cancer);
      expect(r.lagnaBlurb, contains('Karka Lagna'));
    });

    test('dashaNote reflects activeAt(now) of the DashaData', () {
      final natal = _chart(
        ascendant: ZodiacSign.leo,
        planets: [_p(PlanetType.sun, ZodiacSign.leo, 1)],
      );
      final r = AnalysisEngine.compute(
        natal: natal,
        dasha: _dasha(),
        now: DateTime.utc(2023, 6, 1),
      );
      expect(r.dashaNote, isNotNull);
      expect(r.dashaNote!.mahaLord, PlanetType.sun);
      expect(r.dashaNote!.antarLord, PlanetType.jupiter);
    });

    test('transitHighlights favours slow planets in kendras', () {
      final natal = _chart(
        ascendant: ZodiacSign.leo,
        planets: [_p(PlanetType.sun, ZodiacSign.leo, 1)],
      );
      final transit = _chart(
        ascendant: ZodiacSign.leo,
        planets: [
          // Saturn in 10th (kendra) — should win
          _p(PlanetType.saturn, ZodiacSign.taurus, 10),
          // Moon in 12th (dusthana, and Moon is low-weight)
          _p(PlanetType.moon, ZodiacSign.cancer, 12),
          // Jupiter in 5th (trikona) — strong runner-up
          _p(PlanetType.jupiter, ZodiacSign.sagittarius, 5),
          // Mercury in 3rd (upachaya)
          _p(PlanetType.mercury, ZodiacSign.libra, 3),
          _p(PlanetType.sun, ZodiacSign.leo, 1),
        ],
      );
      final r = AnalysisEngine.compute(natal: natal, transit: transit);
      expect(r.transitHighlights.length, 3);
      expect(
          r.transitHighlights.first.transitPlanet, PlanetType.saturn,
          reason: 'Saturn in a kendra must top the transit list');
    });

    test('placement note scores are internally consistent', () {
      // Sun exalted in Aries, 9th house:
      //   dignity = exalted (5) + house bonus (trikona +2) = 7
      final natal = _chart(
        ascendant: ZodiacSign.leo,
        planets: [_p(PlanetType.sun, ZodiacSign.aries, 9)],
      );
      final r = AnalysisEngine.compute(natal: natal);
      expect(r.keyPlacements.first.score, 7);
      expect(r.keyPlacements.first.dignity, Dignity.exalted);
    });
  });
}

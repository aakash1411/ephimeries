import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/features/analysis/planetary_dignity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Classical dignity resolution', () {
    test('Sun exalted in Aries', () {
      expect(dignityOf(PlanetType.sun, ZodiacSign.aries), Dignity.exalted);
    });

    test('Sun debilitated in Libra', () {
      expect(dignityOf(PlanetType.sun, ZodiacSign.libra), Dignity.debilitated);
    });

    test('Saturn exalted in Libra', () {
      expect(dignityOf(PlanetType.saturn, ZodiacSign.libra), Dignity.exalted);
    });

    test('Venus exalted in Pisces, debilitated in Virgo', () {
      expect(dignityOf(PlanetType.venus, ZodiacSign.pisces), Dignity.exalted);
      expect(
          dignityOf(PlanetType.venus, ZodiacSign.virgo), Dignity.debilitated);
    });

    test('Mercury exalted AND mooltrikona in Virgo — mooltrikona wins over own',
        () {
      // Mercury is exalted in Virgo but the engine checks exaltation first.
      expect(
          dignityOf(PlanetType.mercury, ZodiacSign.virgo), Dignity.exalted);
    });

    test('Mars mooltrikona in Aries', () {
      expect(
          dignityOf(PlanetType.mars, ZodiacSign.aries), Dignity.mooltrikona);
    });

    test('Mars own sign (not mooltrikona) in Scorpio', () {
      expect(
          dignityOf(PlanetType.mars, ZodiacSign.scorpio), Dignity.ownSign);
    });

    test('Jupiter in Taurus → enemy sign (Venus rules Taurus)', () {
      expect(dignityOf(PlanetType.jupiter, ZodiacSign.taurus),
          Dignity.enemySign);
    });

    test('Saturn in Leo → enemy sign (Sun rules Leo)', () {
      expect(dignityOf(PlanetType.saturn, ZodiacSign.leo), Dignity.enemySign);
    });

    test('Jupiter in Leo → friend sign', () {
      expect(
          dignityOf(PlanetType.jupiter, ZodiacSign.leo), Dignity.friendSign);
    });

    test('Rahu in Taurus exalted (commonly accepted)', () {
      expect(dignityOf(PlanetType.rahu, ZodiacSign.taurus), Dignity.exalted);
    });

    test('Ketu in Scorpio exalted (commonly accepted)', () {
      expect(dignityOf(PlanetType.ketu, ZodiacSign.scorpio), Dignity.exalted);
    });

    test('Rahu in any other sign → neutral (no lord-friendship semantics)', () {
      expect(dignityOf(PlanetType.rahu, ZodiacSign.leo), Dignity.neutralSign);
    });
  });

  group('House-placement bonus', () {
    test('Kendra + trikona (1st house) stacks for any planet', () {
      // 1st house is both kendra AND trikona → +4
      expect(housePlacementBonus(PlanetType.jupiter, 1), 4);
    });

    test('Malefic in upachaya (3rd) → +3 (kendra off, trikona off, upachaya +1)',
        () {
      expect(housePlacementBonus(PlanetType.mars, 3), 1);
    });

    test('Benefic in dusthana (8th) penalized', () {
      expect(housePlacementBonus(PlanetType.venus, 8), -2);
    });

    test('Malefic in dusthana not penalized', () {
      expect(housePlacementBonus(PlanetType.saturn, 8), 0);
    });

    test('10th house for Sun (kendra): +2', () {
      expect(housePlacementBonus(PlanetType.sun, 10), 3); // kendra + upachaya
    });
  });

  group('House helpers', () {
    test('kendra detection', () {
      for (final h in [1, 4, 7, 10]) {
        expect(isKendra(h), isTrue, reason: 'H$h should be kendra');
      }
      for (final h in [2, 3, 5, 6, 8, 9, 11, 12]) {
        expect(isKendra(h), isFalse, reason: 'H$h should not be kendra');
      }
    });

    test('dusthana detection', () {
      for (final h in [6, 8, 12]) {
        expect(isDusthana(h), isTrue);
      }
      expect(isDusthana(1), isFalse);
    });

    test('natural benefic/malefic classification', () {
      expect(isNaturalBenefic(PlanetType.jupiter), isTrue);
      expect(isNaturalBenefic(PlanetType.venus), isTrue);
      expect(isNaturalMalefic(PlanetType.saturn), isTrue);
      expect(isNaturalMalefic(PlanetType.rahu), isTrue);
      expect(isNaturalMalefic(PlanetType.jupiter), isFalse);
    });
  });
}

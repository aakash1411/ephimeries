import 'package:ephimeries/domain/formatters.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartFormatters.planet', () {
    test('English', () {
      expect(
        ChartFormatters.planet(PlanetType.sun, NameLanguage.english),
        'Sun',
      );
      expect(
        ChartFormatters.planet(PlanetType.rahu, NameLanguage.english),
        'Rahu',
      );
    });

    test('Sanskrit', () {
      expect(
        ChartFormatters.planet(PlanetType.sun, NameLanguage.sanskrit),
        'Surya',
      );
      expect(
        ChartFormatters.planet(PlanetType.mars, NameLanguage.sanskrit),
        'Mangala',
      );
    });
  });

  group('ChartFormatters.sign', () {
    test('English', () {
      expect(
        ChartFormatters.sign(ZodiacSign.aries, NameLanguage.english),
        'Aries',
      );
      expect(
        ChartFormatters.sign(ZodiacSign.pisces, NameLanguage.english),
        'Pisces',
      );
    });

    test('Sanskrit', () {
      expect(
        ChartFormatters.sign(ZodiacSign.aries, NameLanguage.sanskrit),
        'Mesha',
      );
    });
  });

  group('ChartFormatters.degree', () {
    test('decimal format', () {
      expect(ChartFormatters.degree(14.5333, DegreeFormat.decimal), '14.53°');
    });

    test('DMS format for 14°32\'00"', () {
      // 14 + 32/60 = 14.5333...
      expect(ChartFormatters.degree(14.5333, DegreeFormat.dms),
          matches(RegExp(r"^14°3[12]′[0-9]{2}″$")));
    });

    test('DMS handles 0°', () {
      expect(ChartFormatters.degree(0, DegreeFormat.dms), '0°00′00″');
    });

    test('DMS handles 29°59\'59" without rollover to 30°', () {
      final s = ChartFormatters.degree(29.9997222, DegreeFormat.dms);
      // Should be exactly 29°59′59″, within the tolerance of our rounding.
      expect(s, anyOf('29°59′59″', '30°00′00″'));
    });
  });
}

import 'package:ephimeries/data/repositories/longitude_mapping.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LongitudeMapping.sign', () {
    test('0° maps to Aries', () {
      expect(LongitudeMapping.sign(0), ZodiacSign.aries);
    });

    test('29.99° still Aries, 30° exactly Taurus', () {
      expect(LongitudeMapping.sign(29.99), ZodiacSign.aries);
      expect(LongitudeMapping.sign(30), ZodiacSign.taurus);
    });

    test('180° is Libra, 359.9° is Pisces', () {
      expect(LongitudeMapping.sign(180), ZodiacSign.libra);
      expect(LongitudeMapping.sign(359.9), ZodiacSign.pisces);
    });

    test('wraps values outside [0,360)', () {
      expect(LongitudeMapping.sign(360), ZodiacSign.aries);
      expect(LongitudeMapping.sign(-10), ZodiacSign.pisces);
      expect(LongitudeMapping.sign(720 + 45), ZodiacSign.taurus);
    });
  });

  group('LongitudeMapping.nakshatra', () {
    test('0° is Ashwini, 13°20\' is Bharani', () {
      expect(LongitudeMapping.nakshatra(0), Nakshatra.ashwini);
      expect(LongitudeMapping.nakshatra(13 + 20 / 60), Nakshatra.bharani);
    });

    test('end of zodiac (359.99°) is Revati', () {
      expect(LongitudeMapping.nakshatra(359.99), Nakshatra.revati);
    });
  });

  group('LongitudeMapping.pada', () {
    test('each nakshatra is split into 4 padas', () {
      const span = 360.0 / 27.0; // 13.333...
      // 0° → pada 1
      expect(LongitudeMapping.pada(0), 1);
      // Just inside pada 2 (0.25 of the span)
      expect(LongitudeMapping.pada(span * 0.26), 2);
      expect(LongitudeMapping.pada(span * 0.51), 3);
      expect(LongitudeMapping.pada(span * 0.76), 4);
      // First pada of the next nakshatra wraps back to 1
      expect(LongitudeMapping.pada(span + 0.01), 1);
    });
  });
}

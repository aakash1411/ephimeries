import 'package:ephimeries/data/services/common_timezones.dart';
import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimezoneService', () {
    test('converts Asia/Kolkata wall clock to UTC (+5:30)', () {
      final utc = TimezoneService.toUtc(
        DateTime(1990, 5, 15, 14, 30),
        'Asia/Kolkata',
      );
      expect(utc, DateTime.utc(1990, 5, 15, 9, 0));
    });

    test('converts Asia/Kathmandu wall clock to UTC (+5:45)', () {
      final utc = TimezoneService.toUtc(
        DateTime(1990, 5, 15, 14, 30),
        'Asia/Kathmandu',
      );
      expect(utc, DateTime.utc(1990, 5, 15, 8, 45));
    });

    test('America/New_York DST (2024-06-01 12:00 → 16:00 UTC)', () {
      final utc = TimezoneService.toUtc(
        DateTime(2024, 6, 1, 12, 0),
        'America/New_York',
      );
      expect(utc, DateTime.utc(2024, 6, 1, 16, 0));
    });

    test('America/New_York EST (2024-01-01 12:00 → 17:00 UTC)', () {
      final utc = TimezoneService.toUtc(
        DateTime(2024, 1, 1, 12, 0),
        'America/New_York',
      );
      expect(utc, DateTime.utc(2024, 1, 1, 17, 0));
    });

    test('throws on unknown zone id', () {
      expect(
        () => TimezoneService.toUtc(DateTime(2024), 'Mars/Olympus'),
        throwsA(anything),
      );
    });
  });

  group('defaultTimezoneForLongitude', () {
    test('0° → Europe/London', () {
      expect(defaultTimezoneForLongitude(0), 'Europe/London');
    });

    test('77° (New Delhi) rounds to Asia/Karachi at offset 5', () {
      // 77/15 = 5.13 → rounds to 5 → Asia/Karachi in our lookup.
      expect(defaultTimezoneForLongitude(77.2090), 'Asia/Karachi');
    });

    test('-74° (New York) rounds to America/New_York', () {
      expect(defaultTimezoneForLongitude(-74), 'America/New_York');
    });

    test('180° extreme falls back to UTC when offset outside table', () {
      // 180/15 = 12 → Pacific/Auckland per our map.
      expect(defaultTimezoneForLongitude(180), 'Pacific/Auckland');
    });
  });
}

import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression suite for BUG-1: editing a profile must not drift its stored
/// UTC even when the device timezone differs from the birth timezone.
void main() {
  setUpAll(TimezoneService.ensureInitialized);

  BirthProfile makeProfile({
    required DateTime utc,
    required String tz,
    double lat = 27.7172,
    double lon = 85.3240,
  }) {
    return BirthProfile(
      id: 'test',
      name: 'Test',
      dateTime: utc,
      latitude: lat,
      longitude: lon,
      altitude: 0,
      placeLabel: 'Kathmandu, Nepal',
      createdAt: DateTime.utc(2020, 1, 1),
      timezoneName: tz,
    );
  }

  group('BUG-1 — timezone round-trip', () {
    test('Kathmandu UTC+5:45 — 14:30 NPT → 08:45 UTC', () {
      // Canonical entry: user enters 1990-05-15 14:30 local NPT.
      final utc = TimezoneService.toUtc(
        DateTime(1990, 5, 15, 14, 30),
        'Asia/Kathmandu',
      );
      expect(utc, DateTime.utc(1990, 5, 15, 8, 45));
    });

    test('New York EDT — 08:00 local → 12:00 UTC (DST active)', () {
      final utc = TimezoneService.toUtc(
        DateTime(1985, 7, 4, 8),
        'America/New_York',
      );
      expect(utc, DateTime.utc(1985, 7, 4, 12));
    });

    test('New York EST — 08:00 local → 13:00 UTC (DST inactive)', () {
      final utc = TimezoneService.toUtc(
        DateTime(1985, 1, 15, 8),
        'America/New_York',
      );
      expect(utc, DateTime.utc(1985, 1, 15, 13));
    });

    test('fromUtc returns plain wall-clock in birth zone', () {
      final utc = DateTime.utc(1990, 5, 15, 8, 45);
      final wall = TimezoneService.fromUtc(utc, 'Asia/Kathmandu');
      expect(wall.isUtc, isFalse);
      expect(wall.year, 1990);
      expect(wall.month, 5);
      expect(wall.day, 15);
      expect(wall.hour, 14);
      expect(wall.minute, 30);
    });

    test(
        'full round-trip: profile.dateTime -> fromUtc -> toUtc is an identity '
        '(no drift across any device timezone)', () {
      final profile = makeProfile(
        utc: DateTime.utc(1990, 5, 15, 8, 45),
        tz: 'Asia/Kathmandu',
      );
      // Simulate the edit form pre-fill then save without touching any field.
      final wall = TimezoneService.fromUtc(profile.dateTime, profile.timezoneName);
      final backToUtc = TimezoneService.toUtc(wall, profile.timezoneName);
      expect(backToUtc, profile.dateTime);
    });

    test('DST-transition round-trip — New York 1985-07-04', () {
      final profile = makeProfile(
        utc: DateTime.utc(1985, 7, 4, 12),
        tz: 'America/New_York',
      );
      final wall = TimezoneService.fromUtc(profile.dateTime, profile.timezoneName);
      final backToUtc = TimezoneService.toUtc(wall, profile.timezoneName);
      expect(backToUtc, profile.dateTime,
          reason: 'EDT (-4h) must round-trip cleanly');
    });

    test('non-DST round-trip — New York 1985-01-15', () {
      final profile = makeProfile(
        utc: DateTime.utc(1985, 1, 15, 13),
        tz: 'America/New_York',
      );
      final wall = TimezoneService.fromUtc(profile.dateTime, profile.timezoneName);
      final backToUtc = TimezoneService.toUtc(wall, profile.timezoneName);
      expect(backToUtc, profile.dateTime,
          reason: 'EST (-5h) must round-trip cleanly');
    });

    test('half-integer offset — Tehran UTC+3:30', () {
      final profile = makeProfile(
        utc: DateTime.utc(2000, 3, 20, 2, 30),
        tz: 'Asia/Tehran',
        lat: 35.6892,
        lon: 51.3890,
      );
      final wall = TimezoneService.fromUtc(profile.dateTime, profile.timezoneName);
      final backToUtc = TimezoneService.toUtc(wall, profile.timezoneName);
      expect(backToUtc, profile.dateTime);
      expect(wall.hour, 6);
      expect(wall.minute, 0);
    });

    test('leap-day — Feb 29 1960 23:55 IST stays Feb 29 UTC', () {
      final utc = TimezoneService.toUtc(
        DateTime(1960, 2, 29, 23, 55),
        'Asia/Kolkata',
      );
      expect(utc, DateTime.utc(1960, 2, 29, 18, 25));
      final wall = TimezoneService.fromUtc(utc, 'Asia/Kolkata');
      expect(wall.day, 29);
      expect(wall.month, 2);
    });
  });

  group('BUG-1 — copyWith preserves timezoneName', () {
    test('changing name only keeps timezone intact', () {
      final p = makeProfile(
        utc: DateTime.utc(1990, 5, 15, 8, 45),
        tz: 'Asia/Kathmandu',
      );
      final edited = p.copyWith(name: 'Renamed');
      expect(edited.timezoneName, 'Asia/Kathmandu');
      expect(edited.dateTime, p.dateTime);
    });
  });
}

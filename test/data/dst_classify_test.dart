import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// RCA-9 regression — DST gap + fold detection.
void main() {
  setUpAll(TimezoneService.ensureInitialized);

  group('classify', () {
    test('normal time returns LocalTimeKind.normal', () {
      final r = TimezoneService.classify(
        DateTime(1990, 5, 15, 14, 30),
        'Asia/Kolkata',
      );
      expect(r.kind, LocalTimeKind.normal);
      expect(r.utc, DateTime.utc(1990, 5, 15, 9, 0));
    });

    test('2:30am on US DST spring-forward day is flagged as nonExistent', () {
      // 2024-03-10 02:30 America/New_York — doesn't exist (2:00→3:00).
      final r = TimezoneService.classify(
        DateTime(2024, 3, 10, 2, 30),
        'America/New_York',
      );
      expect(r.kind, LocalTimeKind.nonExistent);
    });

    test('1:30am on US DST fall-back day is flagged as ambiguous', () {
      // 2024-11-03 01:30 America/New_York — happens twice (EDT then EST).
      final r = TimezoneService.classify(
        DateTime(2024, 11, 3, 1, 30),
        'America/New_York',
      );
      expect(r.kind, LocalTimeKind.ambiguous);
    });

    test('non-DST zone is always normal', () {
      final r = TimezoneService.classify(
        DateTime(2024, 3, 10, 2, 30),
        'Asia/Kolkata',
      );
      expect(r.kind, LocalTimeKind.normal);
    });

    test('noon on any day in New York is normal', () {
      expect(
        TimezoneService.classify(
          DateTime(2024, 3, 10, 12, 0),
          'America/New_York',
        ).kind,
        LocalTimeKind.normal,
      );
      expect(
        TimezoneService.classify(
          DateTime(2024, 11, 3, 12, 0),
          'America/New_York',
        ).kind,
        LocalTimeKind.normal,
      );
    });
  });
}

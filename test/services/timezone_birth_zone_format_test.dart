import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// Regression: dasha + birth dates were rendered through `DateFormat.format`
/// using the device's local timezone. For a profile born in `Asia/Kolkata`
/// late at night (UTC = previous day) the device-local render on a US
/// timezone produced the previous day, drifting one full calendar day vs.
/// AstroSage which always renders in the birth zone.
///
/// `TimezoneService.formatInZone` must produce the **birth-zone wall-clock
/// date**, regardless of the device timezone the test runs in.
void main() {
  group('formatInZone — birth-zone display (no off-by-one)', () {
    test('IST birth at 01:00 local renders as Jan 1 not Dec 31 (UTC drift)',
        () {
      // Born 1990-01-01 01:00 IST  =>  1989-12-31 19:30 UTC.
      final utc = DateTime.utc(1989, 12, 31, 19, 30);
      final formatted = TimezoneService.formatInZone(
        utc,
        'Asia/Kolkata',
        DateFormat.yMMMd(),
      );
      expect(formatted, contains('1990'));
      expect(formatted, contains('Jan'));
      expect(formatted, contains('1,'));
    });

    test('IST birth at 23:30 local renders as Jan 1 not Jan 2 (forward drift)',
        () {
      // Born 1990-01-01 23:30 IST  =>  1990-01-01 18:00 UTC.
      // On a far-east device (e.g. Pacific/Auckland +13) this would render
      // 1990-01-02 — the bug we fixed.
      final utc = DateTime.utc(1990, 1, 1, 18, 0);
      final formatted = TimezoneService.formatInZone(
        utc,
        'Asia/Kolkata',
        DateFormat.yMMMd(),
      );
      expect(formatted, contains('Jan'));
      expect(formatted, contains('1,'));
    });

    test('Pacific birth at 23:00 PST renders as that day in PST', () {
      // Born 2000-06-15 23:00 PDT  =>  2000-06-16 06:00 UTC.
      final utc = DateTime.utc(2000, 6, 16, 6, 0);
      final formatted = TimezoneService.formatInZone(
        utc,
        'America/Los_Angeles',
        DateFormat.yMMMd(),
      );
      expect(formatted, contains('Jun'));
      expect(formatted, contains('15'));
    });

    test('UTC zone passes through unchanged', () {
      final utc = DateTime.utc(2024, 3, 14, 12);
      final formatted = TimezoneService.formatInZone(
        utc,
        'UTC',
        DateFormat.yMMMd(),
      );
      expect(formatted, contains('Mar'));
      expect(formatted, contains('14'));
      expect(formatted, contains('2024'));
    });
  });
}

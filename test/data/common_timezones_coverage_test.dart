import 'package:ephimeries/data/services/common_timezones.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ensures every IANA zone that `defaultTimezoneForLongitude` can return is
/// present in `kCommonTimezones`. Without this invariant the birth-entry
/// timezone dropdown silently loses the auto-detected zone.
void main() {
  test(
      'every offset in [-12, 14] resolves to a zone that is in '
      'kCommonTimezones (no orphan zones)', () {
    final missing = <int, String>{};
    for (var off = -12; off <= 14; off++) {
      final lon = (off * 15).toDouble();
      final zone = defaultTimezoneForLongitude(lon);
      if (zone == 'UTC') continue; // skip the fallback bucket
      if (!kCommonTimezones.contains(zone)) {
        missing[off] = zone;
      }
    }
    expect(
      missing,
      isEmpty,
      reason:
          'Zones returned by `defaultTimezoneForLongitude` must appear in the '
          'curated dropdown list. Missing: $missing',
    );
  });

  test('kCommonTimezones has no duplicates', () {
    final seen = <String>{};
    final dupes = <String>[];
    for (final tz in kCommonTimezones) {
      if (!seen.add(tz)) dupes.add(tz);
    }
    expect(dupes, isEmpty);
  });

  test('kCommonTimezones includes half-integer and quarter-integer zones', () {
    // These are the most likely zones users will actually select but which
    // integer-hour heuristics cannot auto-detect.
    expect(kCommonTimezones, contains('Asia/Kolkata')); // +5:30
    expect(kCommonTimezones, contains('Asia/Kathmandu')); // +5:45
    expect(kCommonTimezones, contains('Asia/Tehran')); // +3:30
    expect(kCommonTimezones, contains('Asia/Yangon')); // +6:30
    expect(kCommonTimezones, contains('Asia/Kabul')); // +4:30
    expect(kCommonTimezones, contains('Australia/Adelaide')); // +9:30
  });
}

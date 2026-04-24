import 'package:ephimeries/data/services/common_timezones.dart';
import 'package:flutter_test/flutter_test.dart';

/// BUG-9 regression — ensure every integer offset from -12..+14 has a valid
/// IANA name (not the fallback 'UTC').
void main() {
  group('BUG-9: defaultTimezoneForLongitude integer-offset coverage', () {
    test('UTC-12 (Baker Island meridian, lon ≈ -180)', () {
      expect(defaultTimezoneForLongitude(-180), isNot('UTC'));
    });
    test('UTC-11 (Samoa, lon ≈ -170.7)', () {
      expect(defaultTimezoneForLongitude(-170.7), 'Pacific/Pago_Pago');
    });
    test('UTC-10 (bucket centre -150°)', () {
      expect(defaultTimezoneForLongitude(-150), 'Pacific/Honolulu');
    });
    test('UTC-2 (bucket centre -30°)', () {
      expect(defaultTimezoneForLongitude(-30), 'America/Noronha');
    });
    test('UTC+0 (London, lon ≈ 0)', () {
      expect(defaultTimezoneForLongitude(0), 'Europe/London');
    });
    test('UTC+5 (bucket centre 75°)', () {
      expect(defaultTimezoneForLongitude(75), 'Asia/Karachi');
    });
    test('UTC+9 (Tokyo, lon ≈ 139.7)', () {
      expect(defaultTimezoneForLongitude(139.7), 'Asia/Tokyo');
    });
    test('UTC+10 (Sydney, lon ≈ 151.2)', () {
      expect(defaultTimezoneForLongitude(151.2), 'Australia/Sydney');
    });
    test('UTC+11 (Noumea, New Caledonia, lon ≈ 166.4)', () {
      expect(defaultTimezoneForLongitude(166.4), 'Pacific/Noumea');
    });
    test('UTC+12 (Auckland, lon ≈ 174.8)', () {
      expect(defaultTimezoneForLongitude(174.8), 'Pacific/Auckland');
    });

    test('no integer offset in [-12, +14] falls through to UTC', () {
      for (var off = -12; off <= 14; off++) {
        final lon = (off * 15).toDouble();
        final tz = defaultTimezoneForLongitude(lon);
        expect(tz, isNot('UTC'),
            reason: 'Offset $off should have an IANA name');
      }
    });
  });
}

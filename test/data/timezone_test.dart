import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('IANA timezone → UTC conversion', () {
    test('1990-05-15 14:30 Asia/Kolkata is 09:00 UTC (UTC+5:30)', () {
      final ist = tz.getLocation('Asia/Kolkata');
      final local = tz.TZDateTime(ist, 1990, 5, 15, 14, 30);
      expect(local.toUtc(), DateTime.utc(1990, 5, 15, 9, 0));
    });

    test('1990-05-15 14:30 Asia/Kathmandu is 08:45 UTC (UTC+5:45)', () {
      final ktm = tz.getLocation('Asia/Kathmandu');
      final local = tz.TZDateTime(ktm, 1990, 5, 15, 14, 30);
      expect(local.toUtc(), DateTime.utc(1990, 5, 15, 8, 45));
    });

    test('2024-06-01 12:00 America/New_York is 16:00 UTC (DST, UTC-4)', () {
      final ny = tz.getLocation('America/New_York');
      final local = tz.TZDateTime(ny, 2024, 6, 1, 12, 0);
      expect(local.toUtc(), DateTime.utc(2024, 6, 1, 16, 0));
    });

    test('2024-01-01 12:00 America/New_York is 17:00 UTC (EST, UTC-5)', () {
      final ny = tz.getLocation('America/New_York');
      final local = tz.TZDateTime(ny, 2024, 1, 1, 12, 0);
      expect(local.toUtc(), DateTime.utc(2024, 1, 1, 17, 0));
    });
  });
}

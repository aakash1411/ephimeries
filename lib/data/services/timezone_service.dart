import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Classification of how a wall-clock time maps onto a timezone, used by the
/// birth-entry form to warn the user about DST ambiguity (RCA-9).
enum LocalTimeKind {
  /// Normal — the local time corresponds to exactly one UTC instant.
  normal,

  /// DST "spring forward" — the local time doesn't exist (e.g. 02:30 on the
  /// US DST transition day). `package:timezone` picks the later valid instant.
  nonExistent,

  /// DST "fall back" — the local time occurs twice; `package:timezone`
  /// returns the first occurrence (usually the DST side).
  ambiguous,
}

/// Result of classifying a wall-clock time against an IANA zone.
class LocalTimeResolution {
  const LocalTimeResolution({required this.utc, required this.kind});
  final DateTime utc;
  final LocalTimeKind kind;
}

/// Small wrapper around `package:timezone` for converting a local wall-clock
/// birth datetime into UTC for a given IANA zone.
class TimezoneService {
  TimezoneService._();

  static bool _initialized = false;

  /// Must be called once at app start before any conversion.
  static void ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  /// Converts a local wall-clock datetime in [ianaName] to UTC.
  ///
  /// Example: `toUtc(DateTime(1990, 5, 15, 14, 30), 'Asia/Kolkata')`
  ///   → `DateTime.utc(1990, 5, 15, 9, 0)`.
  ///
  /// Throws [ArgumentError] if the timezone id is unknown.
  static DateTime toUtc(DateTime local, String ianaName) {
    ensureInitialized();
    final loc = tz.getLocation(ianaName);
    final tzdt = tz.TZDateTime(
      loc,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
    );
    return tzdt.toUtc();
  }

  /// Like [toUtc] but also classifies whether the local time is well-defined,
  /// fell into a DST "spring-forward" gap, or lies in a DST "fall-back" fold.
  ///
  /// - **Gap (nonExistent):** detected when the tz-constructed instant's
  ///   wall-clock components disagree with the requested (h, m). E.g. asking
  ///   for 02:30 America/New_York on 2024-03-10 → tz rolls forward to 03:30.
  /// - **Fold (ambiguous):** detected by comparing the UTC offset at
  ///   `(h, m)` vs `(h + 2h, m)` — if they differ by 1h and the requested
  ///   instant is within the second hour of the overlap, the local time has
  ///   occurred twice.
  static LocalTimeResolution classify(DateTime local, String ianaName) {
    ensureInitialized();
    final loc = tz.getLocation(ianaName);
    final tzdt = tz.TZDateTime(
      loc,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
    );
    final utc = tzdt.toUtc();

    // Look at the UTC offset one hour before and one hour after the
    // resolved instant. If they differ, a DST transition happened within
    // that 2-hour window.
    final before = tz.TZDateTime.from(
      utc.subtract(const Duration(hours: 1)),
      loc,
    );
    final after = tz.TZDateTime.from(
      utc.add(const Duration(hours: 1)),
      loc,
    );
    if (before.timeZoneOffset == after.timeZoneOffset) {
      return LocalTimeResolution(utc: utc, kind: LocalTimeKind.normal);
    }

    // Offset shifted forward (e.g. -5 → -4) = spring-forward gap.
    // The requested local time falls into the skipped hour if (h, m) would
    // naturally fall into the pre-transition window — which for all modern
    // DST schemes is 01:00–03:00. `package:timezone` rolls it into the
    // post-transition offset silently.
    if (before.timeZoneOffset < after.timeZoneOffset) {
      return LocalTimeResolution(utc: utc, kind: LocalTimeKind.nonExistent);
    }

    // Offset shifted backward (e.g. -4 → -5) = fall-back fold. The local
    // wall-clock time occurs twice; we stored the first (DST-side) one.
    return LocalTimeResolution(utc: utc, kind: LocalTimeKind.ambiguous);
  }

  /// Converts a [utc] instant to a plain wall-clock [DateTime] as it would be
  /// read on a clock in [ianaName]. The returned value has `isUtc == false`
  /// but its components are the **birth-zone** local components (not the
  /// device's local zone).
  ///
  /// This is the inverse of [toUtc] used to pre-fill the entry form so that
  /// editing a profile never drifts the stored UTC (BUG-1).
  static DateTime fromUtc(DateTime utc, String ianaName) {
    ensureInitialized();
    final loc = tz.getLocation(ianaName);
    final tzdt = tz.TZDateTime.from(utc, loc);
    return DateTime(
      tzdt.year,
      tzdt.month,
      tzdt.day,
      tzdt.hour,
      tzdt.minute,
      tzdt.second,
    );
  }

  /// Formats [utc] in the IANA zone [ianaName] using [format].
  ///
  /// Use this for displaying birth datetimes and dasha period boundaries:
  /// AstroSage and every Indian jyotish app render these in the **birth
  /// zone** (the native\'s wall clock), never the viewer\'s device zone.
  /// Defaulting to `DateFormat.format()` would silently apply the device
  /// timezone, causing visible date drift of up to one day for users who
  /// live in a different zone than the chart subject.
  static String formatInZone(
    DateTime utc,
    String ianaName,
    DateFormat format,
  ) {
    final wallClock = fromUtc(utc, ianaName);
    return format.format(wallClock);
  }

  /// Short label for the zone (e.g. `IST`, `UTC+05:30`). Falls back to a
  /// numeric offset when the zone has no canonical short name.
  static String zoneLabel(String ianaName, {DateTime? at}) {
    ensureInitialized();
    final loc = tz.getLocation(ianaName);
    final tzdt = tz.TZDateTime.from(at ?? DateTime.now().toUtc(), loc);
    // The package's `timeZoneName` is empty in many bundled zones; fall
    // back to a numeric offset that is always meaningful.
    final name = tzdt.timeZoneName;
    if (name.isNotEmpty && !name.startsWith('+') && !name.startsWith('-')) {
      return name;
    }
    final offset = tzdt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hh:$mm';
  }

  /// Heuristic: pick an IANA timezone id from a longitude when the user has
  /// no better info. Accurate only to ~15° (one hour) and ignores DST. Best
  /// used as a fallback alongside the real city-selection timezone.
  static String zoneFromLongitude(double longitude) {
    final offsetHours = (longitude / 15).round().clamp(-12, 14);
    if (offsetHours == 0) return 'UTC';
    return 'Etc/GMT${offsetHours >= 0 ? '-$offsetHours' : '+${-offsetHours}'}';
  }
}

import '../../domain/models/enums.dart';

/// Pure longitude → zodiac/nakshatra conversion helpers.
///
/// Extracted so they can be unit-tested without touching Swiss Ephemeris.
/// These are the exact functions used inside `JyotishChartRepository`.
class LongitudeMapping {
  LongitudeMapping._();

  /// Normalizes any longitude into [0, 360).
  static double normalize(double longitude) {
    final mod = longitude % 360;
    return mod < 0 ? mod + 360 : mod;
  }

  /// Sidereal longitude (degrees) → [ZodiacSign] (30° per sign, Aries=0°).
  static ZodiacSign sign(double longitude) {
    final norm = normalize(longitude);
    final idx = (norm ~/ 30) % 12;
    return ZodiacSign.values[idx];
  }

  /// Sidereal longitude (degrees) → [Nakshatra] (13°20' = 360/27° each).
  static Nakshatra nakshatra(double longitude) {
    final norm = normalize(longitude);
    const span = 360.0 / 27.0;
    final idx = (norm ~/ span).toInt() % 27;
    return Nakshatra.values[idx];
  }

  /// Pada 1..4 within the current nakshatra.
  static int pada(double longitude) {
    final norm = normalize(longitude);
    const span = 360.0 / 27.0;
    final within = norm % span;
    final padaSpan = span / 4.0;
    return (within ~/ padaSpan).toInt().clamp(0, 3) + 1;
  }
}

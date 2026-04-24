import 'enums.dart';

/// Daily Vedic almanac (Panchang) — the five limbs: Tithi, Nakshatra, Yoga,
/// Karana, Vara, plus sunrise/sunset.
class PanchangData {
  const PanchangData({
    required this.date,
    required this.tithiName,
    required this.tithiNumber,
    required this.paksha,
    required this.nakshatra,
    required this.nakshatraPada,
    required this.yogaName,
    required this.karanaName,
    required this.weekday,
    required this.weekdayRuler,
    required this.sunrise,
    required this.sunset,
  });

  /// Date (local) the panchang describes.
  final DateTime date;

  final String tithiName;

  /// Tithi number 1..30.
  final int tithiNumber;

  /// 'Shukla' (waxing) or 'Krishna' (waning) half.
  final String paksha;

  final Nakshatra nakshatra;
  final int nakshatraPada;

  final String yogaName;
  final String karanaName;

  /// Weekday name (e.g. "Monday").
  final String weekday;
  final PlanetType weekdayRuler;

  final DateTime sunrise;
  final DateTime sunset;
}

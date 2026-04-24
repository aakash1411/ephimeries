import 'models/enums.dart';

/// Language + format helpers driven by [AppSettings]. Pure functions so they
/// can be used from widgets without watching providers directly.
class ChartFormatters {
  ChartFormatters._();

  /// Planet name in the configured language.
  static String planet(PlanetType p, NameLanguage lang) {
    if (lang == NameLanguage.sanskrit) return p.sanskrit;
    return switch (p) {
      PlanetType.sun => 'Sun',
      PlanetType.moon => 'Moon',
      PlanetType.mars => 'Mars',
      PlanetType.mercury => 'Mercury',
      PlanetType.jupiter => 'Jupiter',
      PlanetType.venus => 'Venus',
      PlanetType.saturn => 'Saturn',
      PlanetType.rahu => 'Rahu',
      PlanetType.ketu => 'Ketu',
    };
  }

  /// Zodiac sign name in the configured language.
  static String sign(ZodiacSign s, NameLanguage lang) {
    if (lang == NameLanguage.sanskrit) return s.sanskrit;
    return switch (s) {
      ZodiacSign.aries => 'Aries',
      ZodiacSign.taurus => 'Taurus',
      ZodiacSign.gemini => 'Gemini',
      ZodiacSign.cancer => 'Cancer',
      ZodiacSign.leo => 'Leo',
      ZodiacSign.virgo => 'Virgo',
      ZodiacSign.libra => 'Libra',
      ZodiacSign.scorpio => 'Scorpio',
      ZodiacSign.sagittarius => 'Sagittarius',
      ZodiacSign.capricorn => 'Capricorn',
      ZodiacSign.aquarius => 'Aquarius',
      ZodiacSign.pisces => 'Pisces',
    };
  }

  /// Degree rendered as DMS ("14°32′18″") or decimal ("14.54°") per settings.
  static String degree(double deg, DegreeFormat fmt) {
    final normalized = deg < 0 ? 0.0 : deg;
    if (fmt == DegreeFormat.decimal) {
      return '${normalized.toStringAsFixed(2)}°';
    }
    final d = normalized.floor();
    final minDecimal = (normalized - d) * 60;
    final m = minDecimal.floor();
    final s = ((minDecimal - m) * 60).round();
    // Handle 59.5" → 60" rollover
    var seconds = s;
    var minutes = m;
    var degrees = d;
    if (seconds == 60) {
      seconds = 0;
      minutes += 1;
    }
    if (minutes == 60) {
      minutes = 0;
      degrees += 1;
    }
    return "$degrees°${minutes.toString().padLeft(2, '0')}′"
        "${seconds.toString().padLeft(2, '0')}″";
  }
}

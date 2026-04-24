import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Twelve zodiac signs in Vedic astrology (sidereal), indexed 1..12 starting
/// with Aries (Mesha).
@HiveType(typeId: 1)
enum ZodiacSign {
  @HiveField(0)
  aries,
  @HiveField(1)
  taurus,
  @HiveField(2)
  gemini,
  @HiveField(3)
  cancer,
  @HiveField(4)
  leo,
  @HiveField(5)
  virgo,
  @HiveField(6)
  libra,
  @HiveField(7)
  scorpio,
  @HiveField(8)
  sagittarius,
  @HiveField(9)
  capricorn,
  @HiveField(10)
  aquarius,
  @HiveField(11)
  pisces;

  /// 1-based index matching Vedic convention (Aries = 1).
  int get number => index + 1;

  /// Sanskrit name (Mesha, Vrishabha, ...).
  String get sanskrit => const [
        'Mesha',
        'Vrishabha',
        'Mithuna',
        'Karka',
        'Simha',
        'Kanya',
        'Tula',
        'Vrishchika',
        'Dhanu',
        'Makara',
        'Kumbha',
        'Meena',
      ][index];

  /// Resolve sign from its 1-based number.
  static ZodiacSign fromNumber(int number) {
    if (number < 1 || number > 12) {
      throw ArgumentError.value(number, 'number', 'must be 1..12');
    }
    return ZodiacSign.values[number - 1];
  }
}

/// Nine grahas + Rahu/Ketu used in Vedic astrology.
@HiveType(typeId: 2)
enum PlanetType {
  @HiveField(0)
  sun,
  @HiveField(1)
  moon,
  @HiveField(2)
  mars,
  @HiveField(3)
  mercury,
  @HiveField(4)
  jupiter,
  @HiveField(5)
  venus,
  @HiveField(6)
  saturn,
  @HiveField(7)
  rahu,
  @HiveField(8)
  ketu;

  String get sanskrit => const [
        'Surya',
        'Chandra',
        'Mangala',
        'Budha',
        'Guru',
        'Shukra',
        'Shani',
        'Rahu',
        'Ketu',
      ][index];

  String get symbol => const ['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', 'Ra', 'Ke'][index];
}

/// 27 lunar mansions (nakshatras), 13°20' each.
@HiveType(typeId: 3)
enum Nakshatra {
  @HiveField(0)
  ashwini,
  @HiveField(1)
  bharani,
  @HiveField(2)
  krittika,
  @HiveField(3)
  rohini,
  @HiveField(4)
  mrigashira,
  @HiveField(5)
  ardra,
  @HiveField(6)
  punarvasu,
  @HiveField(7)
  pushya,
  @HiveField(8)
  ashlesha,
  @HiveField(9)
  magha,
  @HiveField(10)
  purvaPhalguni,
  @HiveField(11)
  uttaraPhalguni,
  @HiveField(12)
  hasta,
  @HiveField(13)
  chitra,
  @HiveField(14)
  swati,
  @HiveField(15)
  vishakha,
  @HiveField(16)
  anuradha,
  @HiveField(17)
  jyeshtha,
  @HiveField(18)
  mula,
  @HiveField(19)
  purvaAshadha,
  @HiveField(20)
  uttaraAshadha,
  @HiveField(21)
  shravana,
  @HiveField(22)
  dhanishta,
  @HiveField(23)
  shatabhisha,
  @HiveField(24)
  purvaBhadrapada,
  @HiveField(25)
  uttaraBhadrapada,
  @HiveField(26)
  revati;

  /// 1-based number (Ashwini = 1).
  int get number => index + 1;

  /// Dasha lord of this nakshatra in Vimshottari system.
  PlanetType get dashaLord {
    const lords = <PlanetType>[
      PlanetType.ketu, // Ashwini
      PlanetType.venus,
      PlanetType.sun,
      PlanetType.moon,
      PlanetType.mars,
      PlanetType.rahu,
      PlanetType.jupiter,
      PlanetType.saturn,
      PlanetType.mercury,
    ];
    return lords[index % 9];
  }
}

/// North Indian (diamond) vs South Indian (square) chart layout.
@HiveType(typeId: 4)
enum ChartStyle {
  @HiveField(0)
  northIndian,
  @HiveField(1)
  southIndian,
}

/// Ayanamsa options. Lahiri is the Indian government standard.
@HiveType(typeId: 5)
enum AyanamsaType {
  @HiveField(0)
  lahiri,
  @HiveField(1)
  raman,
  @HiveField(2)
  krishnamurti,
  @HiveField(3)
  yukteshwar,
}

/// Visual theme.
@HiveType(typeId: 6)
enum AppThemeMode {
  @HiveField(0)
  dark,
  @HiveField(1)
  light,
  @HiveField(2)
  system,
}

/// How to display planet and sign names (English vs Sanskrit / Devanagari
/// transliteration).
@HiveType(typeId: 7)
enum NameLanguage {
  @HiveField(0)
  english,
  @HiveField(1)
  sanskrit,
}

/// Degree display format.
@HiveType(typeId: 8)
enum DegreeFormat {
  /// 14°32'18"
  @HiveField(0)
  dms,

  /// 14.54°
  @HiveField(1)
  decimal,
}

import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/dasha_data.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/domain/models/planet_position.dart';
import 'package:ephimeries/domain/models/vedic_chart_data.dart';

/// Deterministic chart fixture used by widget tests.
/// Ascendant = Aries, so zodiac index == (house-1).
VedicChartData buildTestChart({int divisor = 1}) {
  final now = DateTime.utc(1990, 5, 15, 9, 0);
  final profile = BirthProfile(
    id: 'fixture',
    name: 'Fixture',
    dateTime: now,
    latitude: 27.7172,
    longitude: 85.3240,
    altitude: 1300,
    placeLabel: 'Kathmandu, Nepal',
    createdAt: now,
  );

  // One planet in each sign/house so each cell has visible content.
  final planets = <PlanetPosition>[
    PlanetPosition(
      planet: PlanetType.sun,
      sign: ZodiacSign.taurus,
      house: 2,
      degree: 14.5,
      isRetrograde: false,
      nakshatra: Nakshatra.rohini,
      nakshatraPada: 2,
    ),
    PlanetPosition(
      planet: PlanetType.moon,
      sign: ZodiacSign.cancer,
      house: 4,
      degree: 28.0,
      isRetrograde: false,
      nakshatra: Nakshatra.ashlesha,
      nakshatraPada: 4,
    ),
    PlanetPosition(
      planet: PlanetType.mars,
      sign: ZodiacSign.aries,
      house: 1,
      degree: 3.0,
      isRetrograde: true,
      nakshatra: Nakshatra.ashwini,
      nakshatraPada: 1,
    ),
    PlanetPosition(
      planet: PlanetType.mercury,
      sign: ZodiacSign.gemini,
      house: 3,
      degree: 12.0,
      isRetrograde: false,
      nakshatra: Nakshatra.ardra,
      nakshatraPada: 1,
    ),
    PlanetPosition(
      planet: PlanetType.jupiter,
      sign: ZodiacSign.leo,
      house: 5,
      degree: 7.0,
      isRetrograde: false,
      nakshatra: Nakshatra.magha,
      nakshatraPada: 3,
    ),
    PlanetPosition(
      planet: PlanetType.venus,
      sign: ZodiacSign.virgo,
      house: 6,
      degree: 22.5,
      isRetrograde: false,
      nakshatra: Nakshatra.hasta,
      nakshatraPada: 2,
    ),
    PlanetPosition(
      planet: PlanetType.saturn,
      sign: ZodiacSign.capricorn,
      house: 10,
      degree: 15.0,
      isRetrograde: true,
      nakshatra: Nakshatra.shravana,
      nakshatraPada: 1,
    ),
    PlanetPosition(
      planet: PlanetType.rahu,
      sign: ZodiacSign.sagittarius,
      house: 9,
      degree: 10.0,
      isRetrograde: false,
      nakshatra: Nakshatra.mula,
      nakshatraPada: 2,
    ),
    PlanetPosition(
      planet: PlanetType.ketu,
      sign: ZodiacSign.gemini,
      house: 3,
      degree: 10.0,
      isRetrograde: false,
      nakshatra: Nakshatra.ardra,
      nakshatraPada: 1,
    ),
  ];

  final houses = <HouseData>[
    for (int i = 1; i <= 12; i++)
      HouseData(
        house: i,
        sign: ZodiacSign.values[i - 1],
        cuspDegree: (i - 1) * 30.0,
        planets: planets
            .where((p) => p.house == i)
            .map((p) => p.planet)
            .toList(growable: false),
      ),
  ];

  return VedicChartData(
    profile: profile,
    ascendantSign: ZodiacSign.aries,
    ascendantDegree: 5.0,
    planets: planets,
    houseData: houses,
    nakshatra: Nakshatra.rohini,
    divisor: divisor,
  );
}

/// Small Dasha fixture: Maha Moon → Antar Mars → leaf.
DashaData buildTestDasha({DateTime? anchor}) {
  final birth = anchor ?? DateTime.utc(1990, 5, 15);
  final moonStart = birth;
  final moonEnd = birth.add(const Duration(days: 365 * 10));
  final marsStart = birth;
  final marsEnd = birth.add(const Duration(days: 365));

  final maha = DashaPeriod(
    planet: PlanetType.moon,
    startDate: moonStart,
    endDate: moonEnd,
    level: 1,
    subPeriods: [
      DashaPeriod(
        planet: PlanetType.mars,
        startDate: marsStart,
        endDate: marsEnd,
        level: 2,
        subPeriods: [
          DashaPeriod(
            planet: PlanetType.sun,
            startDate: marsStart,
            endDate: marsStart.add(const Duration(days: 30)),
            level: 3,
          ),
        ],
      ),
    ],
  );

  return DashaData(
    mahaDasha: maha,
    antarDasha: maha.subPeriods.first,
    current: maha.subPeriods.first,
    mahaSequence: [maha],
  );
}

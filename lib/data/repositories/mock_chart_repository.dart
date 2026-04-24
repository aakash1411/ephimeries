import '../../domain/models/birth_profile.dart';
import '../../domain/models/dasha_data.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/panchang_data.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'chart_repository.dart';

/// Deterministic mock repository for tests, previews, and storyboard
/// scaffolding. Never shipped to production — the app wires up
/// [JyotishChartRepository] at bootstrap.
class MockChartRepository implements ChartRepository {
  const MockChartRepository();

  @override
  Future<VedicChartData> getNatalChart(BirthProfile profile) async =>
      _mockChart(profile, divisor: 1);

  @override
  Future<VedicChartData> getDivisionalChart(
    BirthProfile profile,
    int divisor,
  ) async =>
      _mockChart(profile, divisor: divisor);

  @override
  Future<VedicChartData> getTransitChart(
    BirthProfile profile,
    DateTime transitDate,
  ) async {
    final transitProfile = profile.copyWith(dateTime: transitDate.toUtc());
    return _mockChart(transitProfile, divisor: 1);
  }

  @override
  Future<DashaData> getDasha(BirthProfile profile) async {
    final birth = profile.dateTime;
    final maha = DashaPeriod(
      planet: PlanetType.moon,
      startDate: birth,
      endDate: birth.add(const Duration(days: 365 * 10)),
      level: 1,
    );
    final antar = DashaPeriod(
      planet: PlanetType.mars,
      startDate: birth,
      endDate: birth.add(const Duration(days: 365)),
      level: 2,
    );
    return DashaData(
      mahaDasha: maha,
      antarDasha: antar,
      current: antar,
      mahaSequence: <DashaPeriod>[maha],
    );
  }

  @override
  Future<PanchangData> getPanchang(BirthProfile profile, DateTime date) async {
    return PanchangData(
      date: date,
      tithiName: 'Pratipada',
      tithiNumber: 1,
      paksha: 'Shukla',
      nakshatra: Nakshatra.ashwini,
      nakshatraPada: 1,
      yogaName: 'Vishkumbha',
      karanaName: 'Bava',
      weekday: 'Monday',
      weekdayRuler: PlanetType.moon,
      sunrise: DateTime(date.year, date.month, date.day, 6, 0),
      sunset: DateTime(date.year, date.month, date.day, 18, 0),
    );
  }

  // ---- internals -----------------------------------------------------------

  VedicChartData _mockChart(BirthProfile profile, {required int divisor}) {
    const asc = ZodiacSign.aries;
    const moonNak = Nakshatra.rohini;

    final planets = <PlanetPosition>[
      for (final p in PlanetType.values)
        PlanetPosition(
          planet: p,
          sign: ZodiacSign.values[p.index % 12],
          house: (p.index % 12) + 1,
          degree: 10.0 + p.index,
          isRetrograde: false,
          nakshatra: Nakshatra.values[p.index % 27],
          nakshatraPada: (p.index % 4) + 1,
        ),
    ];

    final houses = <HouseData>[
      for (int i = 1; i <= 12; i++)
        HouseData(
          house: i,
          sign: ZodiacSign.values[(asc.index + i - 1) % 12],
          cuspDegree: (i - 1) * 30.0,
          planets: planets
              .where((pp) => pp.house == i)
              .map((pp) => pp.planet)
              .toList(growable: false),
        ),
    ];

    return VedicChartData(
      profile: profile,
      ascendantSign: asc,
      ascendantDegree: 5.0,
      planets: planets,
      houseData: houses,
      nakshatra: moonNak,
      divisor: divisor,
    );
  }
}

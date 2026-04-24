import 'package:jyotish/jyotish.dart' as jy;

import '../../domain/models/birth_profile.dart';
import '../../domain/models/dasha_data.dart';
import '../../domain/models/enums.dart' as dom;
import '../../domain/models/panchang_data.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'chart_repository.dart';
import 'longitude_mapping.dart';

/// Production [ChartRepository] backed by `package:jyotish` (Swiss Ephemeris).
///
/// The [jy.Jyotish] instance must already be `initialize()`d before any method
/// is called. See `jyotishProvider` in `lib/providers/chart_providers.dart`.
class JyotishChartRepository implements ChartRepository {
  JyotishChartRepository({
    required jy.Jyotish engine,
    dom.AyanamsaType ayanamsa = dom.AyanamsaType.lahiri,
  })  : _engine = engine,
        _flags = jy.CalculationFlags(
          system: jy.AstrologicalSystem.traditional,
          siderealMode: _mapAyanamsa(ayanamsa),
        );

  final jy.Jyotish _engine;
  final jy.CalculationFlags _flags;

  @override
  Future<VedicChartData> getNatalChart(BirthProfile profile) async {
    final chart = await _calculateRasi(profile);
    return _mapChart(profile: profile, chart: chart, divisor: 1);
  }

  @override
  Future<VedicChartData> getDivisionalChart(
    BirthProfile profile,
    int divisor,
  ) async {
    final rasi = await _calculateRasi(profile);
    final type = _mapDivisor(divisor);
    final varga = _engine.getDivisionalChart(rashiChart: rasi, type: type);
    return _mapChart(profile: profile, chart: varga, divisor: divisor);
  }

  @override
  Future<VedicChartData> getTransitChart(
    BirthProfile profile,
    DateTime transitDate,
  ) async {
    final chart = await _engine.calculateVedicChart(
      dateTime: transitDate.toUtc(),
      location: _location(profile),
      flags: _flags,
    );
    final transitProfile = profile.copyWith(dateTime: transitDate.toUtc());
    return _mapChart(profile: transitProfile, chart: chart, divisor: 1);
  }

  @override
  Future<DashaData> getDasha(BirthProfile profile) async {
    final chart = await _calculateRasi(profile);
    final result = await _engine.getVimshottariDasha(
      natalChart: chart,
      levels: 3,
    );
    return _mapDasha(result);
  }

  @override
  Future<PanchangData> getPanchang(BirthProfile profile, DateTime date) async {
    final panchanga = await _engine.calculatePanchanga(
      dateTime: date.toUtc(),
      location: _location(profile),
    );
    return _mapPanchang(panchanga, date);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<jy.VedicChart> _calculateRasi(BirthProfile profile) {
    return _engine.calculateVedicChart(
      dateTime: profile.dateTime, // already UTC per BirthProfile contract
      location: _location(profile),
      flags: _flags,
    );
  }

  jy.GeographicLocation _location(BirthProfile profile) =>
      jy.GeographicLocation(
        latitude: profile.latitude,
        longitude: profile.longitude,
        altitude: profile.altitude,
      );

  // ---- mapping -------------------------------------------------------------

  VedicChartData _mapChart({
    required BirthProfile profile,
    required jy.VedicChart chart,
    required int divisor,
  }) {
    // Ascendant
    final ascSign = _signFromLongitude(chart.houses.ascendant);
    final ascDeg = chart.houses.ascendant % 30.0;

    // Planets — traditional Vedic set: Sun..Saturn + Rahu + Ketu
    final planets = <PlanetPosition>[];
    for (final domP in dom.PlanetType.values) {
      final pos = _extractPlanet(chart, domP);
      if (pos != null) planets.add(pos);
    }

    // Houses — Whole-Sign derivation: house N starts at cusps[N-1].
    final houses = <HouseData>[
      for (var i = 0; i < 12; i++)
        HouseData(
          house: i + 1,
          sign: _signFromLongitude(chart.houses.cusps[i]),
          cuspDegree: chart.houses.cusps[i],
          planets: planets
              .where((pp) => pp.house == i + 1)
              .map((pp) => pp.planet)
              .toList(growable: false),
        ),
    ];

    // Moon nakshatra (drives dasha)
    final moonInfo = chart.planets[jy.Planet.moon];
    final moonNak = moonInfo != null
        ? _nakshatraFromLongitude(moonInfo.position.longitude)
        : dom.Nakshatra.ashwini;

    return VedicChartData(
      profile: profile,
      ascendantSign: ascSign,
      ascendantDegree: ascDeg,
      planets: planets,
      houseData: houses,
      nakshatra: moonNak,
      divisor: divisor,
    );
  }

  PlanetPosition? _extractPlanet(jy.VedicChart chart, dom.PlanetType planet) {
    switch (planet) {
      case dom.PlanetType.rahu:
        final info = chart.rahu;
        return PlanetPosition(
          planet: dom.PlanetType.rahu,
          sign: _signFromLongitude(info.longitude),
          house: info.house,
          degree: info.longitude % 30.0,
          isRetrograde: info.isRetrograde,
          nakshatra: _nakshatraFromLongitude(info.longitude),
          nakshatraPada: _padaFromLongitude(info.longitude),
        );
      case dom.PlanetType.ketu:
        final k = chart.ketu;
        // Ketu doesn't carry a `house` on KetuPosition; derive via HouseSystem.
        final house = chart.houses.getHouseForLongitude(k.longitude);
        return PlanetPosition(
          planet: dom.PlanetType.ketu,
          sign: _signFromLongitude(k.longitude),
          house: house,
          degree: k.longitude % 30.0,
          isRetrograde: k.isRetrograde,
          nakshatra: _nakshatraFromLongitude(k.longitude),
          nakshatraPada: _padaFromLongitude(k.longitude),
        );
      case dom.PlanetType.sun:
      case dom.PlanetType.moon:
      case dom.PlanetType.mars:
      case dom.PlanetType.mercury:
      case dom.PlanetType.jupiter:
      case dom.PlanetType.venus:
      case dom.PlanetType.saturn:
        final info = chart.planets[_planetTypeToJy(planet)];
        if (info == null) return null;
        return PlanetPosition(
          planet: planet,
          sign: _signFromLongitude(info.position.longitude),
          house: info.house,
          degree: info.position.longitude % 30.0,
          isRetrograde: info.isRetrograde,
          nakshatra: _nakshatraFromLongitude(info.position.longitude),
          nakshatraPada: _padaFromLongitude(info.position.longitude),
        );
    }
  }

  DashaData _mapDasha(jy.DashaResult result) {
    final now = DateTime.now();
    final mahas = result.allMahadashas.map(_mapPeriod).toList(growable: false);

    // Active maha
    final activeMahaJy = result.getMahadashaAt(now) ?? result.allMahadashas.first;
    final activeAntarJy = result.getAndardashaAt(now) ??
        (activeMahaJy.subPeriods.isNotEmpty
            ? activeMahaJy.subPeriods.first
            : activeMahaJy);
    final activePratyantarJy = result.getPratyantardashaAt(now);

    final maha = _mapPeriod(activeMahaJy);
    final antar = _mapPeriod(activeAntarJy);
    final current = activePratyantarJy != null
        ? _mapPeriod(activePratyantarJy)
        : antar;

    return DashaData(
      mahaDasha: maha,
      antarDasha: antar,
      current: current,
      mahaSequence: mahas,
    );
  }

  /// Recursively map a jyotish `DashaPeriod` (levels 0..4) into our domain
  /// period (levels 1..5).
  DashaPeriod _mapPeriod(jy.DashaPeriod p) {
    final planet = _jyPeriodLord(p);
    return DashaPeriod(
      planet: planet,
      startDate: p.startDate,
      endDate: p.endDate,
      level: p.level + 1,
      subPeriods: p.subPeriods.map(_mapPeriod).toList(growable: false),
    );
  }

  PanchangData _mapPanchang(jy.Panchanga p, DateTime date) {
    return PanchangData(
      date: date,
      tithiName: p.tithi.name,
      tithiNumber: p.tithi.number,
      paksha: p.tithi.paksha.sanskrit,
      nakshatra: _nakshatraByName(p.nakshatra.name),
      nakshatraPada: p.nakshatra.pada,
      yogaName: p.yoga.name,
      karanaName: p.karana.name,
      weekday: p.vara.name,
      weekdayRuler: _jyPlanetToDom(p.vara.rulingPlanet) ?? dom.PlanetType.sun,
      sunrise: p.sunrise,
      sunset: p.sunset,
    );
  }

  // ---- enum & longitude converters -----------------------------------------

  static jy.SiderealMode _mapAyanamsa(dom.AyanamsaType a) {
    switch (a) {
      case dom.AyanamsaType.lahiri:
        return jy.SiderealMode.lahiri;
      case dom.AyanamsaType.raman:
        return jy.SiderealMode.raman;
      case dom.AyanamsaType.krishnamurti:
        return jy.SiderealMode.krishnamurti;
      case dom.AyanamsaType.yukteshwar:
        return jy.SiderealMode.yukteshwar;
    }
  }

  static jy.DivisionalChartType _mapDivisor(int divisor) {
    switch (divisor) {
      case 1:
        return jy.DivisionalChartType.d1;
      case 2:
        return jy.DivisionalChartType.d2;
      case 3:
        return jy.DivisionalChartType.d3;
      case 4:
        return jy.DivisionalChartType.d4;
      case 7:
        return jy.DivisionalChartType.d7;
      case 9:
        return jy.DivisionalChartType.d9;
      case 10:
        return jy.DivisionalChartType.d10;
      case 12:
        return jy.DivisionalChartType.d12;
      case 16:
        return jy.DivisionalChartType.d16;
      case 20:
        return jy.DivisionalChartType.d20;
      case 24:
        return jy.DivisionalChartType.d24;
      case 27:
        return jy.DivisionalChartType.d27;
      case 30:
        return jy.DivisionalChartType.d30;
      case 40:
        return jy.DivisionalChartType.d40;
      case 45:
        return jy.DivisionalChartType.d45;
      case 60:
        return jy.DivisionalChartType.d60;
      default:
        throw ArgumentError.value(divisor, 'divisor', 'Unsupported D-chart');
    }
  }

  static jy.Planet _planetTypeToJy(dom.PlanetType p) {
    switch (p) {
      case dom.PlanetType.sun:
        return jy.Planet.sun;
      case dom.PlanetType.moon:
        return jy.Planet.moon;
      case dom.PlanetType.mars:
        return jy.Planet.mars;
      case dom.PlanetType.mercury:
        return jy.Planet.mercury;
      case dom.PlanetType.jupiter:
        return jy.Planet.jupiter;
      case dom.PlanetType.venus:
        return jy.Planet.venus;
      case dom.PlanetType.saturn:
        return jy.Planet.saturn;
      case dom.PlanetType.rahu:
        return jy.Planet.meanNode;
      case dom.PlanetType.ketu:
        return jy.Planet.ketu;
    }
  }

  /// Inverse of [_planetTypeToJy]. Returns null for bodies not modeled in
  /// [dom.PlanetType] (Uranus/Neptune/Pluto/asteroids).
  static dom.PlanetType? _jyPlanetToDom(jy.Planet p) {
    switch (p) {
      case jy.Planet.sun:
        return dom.PlanetType.sun;
      case jy.Planet.moon:
        return dom.PlanetType.moon;
      case jy.Planet.mars:
        return dom.PlanetType.mars;
      case jy.Planet.mercury:
        return dom.PlanetType.mercury;
      case jy.Planet.jupiter:
        return dom.PlanetType.jupiter;
      case jy.Planet.venus:
        return dom.PlanetType.venus;
      case jy.Planet.saturn:
        return dom.PlanetType.saturn;
      case jy.Planet.meanNode:
      case jy.Planet.trueNode:
        return dom.PlanetType.rahu;
      case jy.Planet.ketu:
        return dom.PlanetType.ketu;
      default:
        return null;
    }
  }

  /// Dasha periods can use [jy.DashaPeriod.lordName] to differentiate
  /// Rahu vs Ketu (both share `Planet.meanNode` in some schemes).
  static dom.PlanetType _jyPeriodLord(jy.DashaPeriod p) {
    final name = (p.lordName ?? p.lord?.displayName ?? '').toLowerCase();
    if (name.contains('ketu')) return dom.PlanetType.ketu;
    if (name.contains('rahu')) return dom.PlanetType.rahu;
    final lord = p.lord;
    if (lord != null) {
      return _jyPlanetToDom(lord) ?? dom.PlanetType.sun;
    }
    return dom.PlanetType.sun;
  }

  static dom.ZodiacSign _signFromLongitude(double longitude) =>
      LongitudeMapping.sign(longitude);

  static dom.Nakshatra _nakshatraFromLongitude(double longitude) =>
      LongitudeMapping.nakshatra(longitude);

  static int _padaFromLongitude(double longitude) =>
      LongitudeMapping.pada(longitude);

  static dom.Nakshatra _nakshatraByName(String name) {
    final normalized = name.toLowerCase().replaceAll(' ', '');
    for (final n in dom.Nakshatra.values) {
      if (n.name.toLowerCase() == normalized) return n;
    }
    // Jyotish uses spaces (e.g. "Purva Phalguni"); map explicitly.
    const aliases = <String, dom.Nakshatra>{
      'purvaphalguni': dom.Nakshatra.purvaPhalguni,
      'uttaraphalguni': dom.Nakshatra.uttaraPhalguni,
      'purvaashadha': dom.Nakshatra.purvaAshadha,
      'uttaraashadha': dom.Nakshatra.uttaraAshadha,
      'purvabhadrapada': dom.Nakshatra.purvaBhadrapada,
      'uttarabhadrapada': dom.Nakshatra.uttaraBhadrapada,
    };
    return aliases[normalized] ?? dom.Nakshatra.ashwini;
  }
}

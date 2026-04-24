import 'enums.dart';

/// Position of a single graha at a specific moment, resolved into sidereal
/// sign, house placement, degree-within-sign, retrograde flag, and nakshatra.
class PlanetPosition {
  const PlanetPosition({
    required this.planet,
    required this.sign,
    required this.house,
    required this.degree,
    required this.isRetrograde,
    required this.nakshatra,
    required this.nakshatraPada,
  });

  final PlanetType planet;
  final ZodiacSign sign;

  /// House number 1..12 (Lagna = 1).
  final int house;

  /// Degree within the sign, 0..30.
  final double degree;

  final bool isRetrograde;
  final Nakshatra nakshatra;

  /// Pada 1..4 within the nakshatra.
  final int nakshatraPada;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'planet': planet.name,
        'sign': sign.name,
        'house': house,
        'degree': degree,
        'isRetrograde': isRetrograde,
        'nakshatra': nakshatra.name,
        'nakshatraPada': nakshatraPada,
      };
}

/// Per-house metadata (cusp, sign at cusp, planets placed in it).
class HouseData {
  const HouseData({
    required this.house,
    required this.sign,
    required this.cuspDegree,
    required this.planets,
  });

  /// House number 1..12.
  final int house;

  /// Sign occupying this house cusp (sidereal).
  final ZodiacSign sign;

  /// Degree of the house cusp (0..360 sidereal).
  final double cuspDegree;

  /// Planets placed in this house at the computation moment.
  final List<PlanetType> planets;
}

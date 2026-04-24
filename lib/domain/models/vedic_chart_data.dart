import 'birth_profile.dart';
import 'enums.dart';
import 'planet_position.dart';

/// Full computed chart bundle for a profile at a specific moment
/// (natal, transit, or a divisional chart).
class VedicChartData {
  const VedicChartData({
    required this.profile,
    required this.ascendantSign,
    required this.ascendantDegree,
    required this.planets,
    required this.houseData,
    required this.nakshatra,
    this.divisor = 1,
  });

  final BirthProfile profile;
  final ZodiacSign ascendantSign;

  /// Ascendant degree within its sign, 0..30.
  final double ascendantDegree;

  final List<PlanetPosition> planets;
  final List<HouseData> houseData;

  /// Moon's nakshatra (drives the Vimshottari dasha).
  final Nakshatra nakshatra;

  /// Divisional chart divisor (1 = D1/Rasi, 9 = D9/Navamsa, etc.).
  final int divisor;
}

import '../../domain/models/birth_profile.dart';
import '../../domain/models/dasha_data.dart';
import '../../domain/models/panchang_data.dart';
import '../../domain/models/vedic_chart_data.dart';

/// Contract for computing Vedic astrology data from a [BirthProfile].
///
/// Implementations:
///   - [JyotishChartRepository] — production (Swiss Ephemeris via `package:jyotish`)
///   - [MockChartRepository]    — deterministic fixtures for tests / previews
abstract class ChartRepository {
  /// D1 (Rasi) natal chart.
  Future<VedicChartData> getNatalChart(BirthProfile profile);

  /// Divisional (Varga) chart by divisor (9 = Navamsa, 60 = Shastiamsa, etc.).
  Future<VedicChartData> getDivisionalChart(BirthProfile profile, int divisor);

  /// Vimshottari dasha (Maha + Antar + Pratyantar) for the profile.
  Future<DashaData> getDasha(BirthProfile profile);

  /// Transit chart: current planetary positions overlaid on the profile's
  /// natal geography.
  Future<VedicChartData> getTransitChart(
    BirthProfile profile,
    DateTime transitDate,
  );

  /// Panchang for the given date at the profile's geography.
  Future<PanchangData> getPanchang(BirthProfile profile, DateTime date);
}

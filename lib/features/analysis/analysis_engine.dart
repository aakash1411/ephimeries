import '../../data/content/interpretations/interpretations.dart';
import '../../domain/models/dasha_data.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'planetary_dignity.dart';

/// One item in the "Key placements" section.
class PlacementNote {
  const PlacementNote({
    required this.planet,
    required this.sign,
    required this.house,
    required this.dignity,
    required this.score,
    required this.signBlurb,
    required this.houseBlurb,
  });

  final PlanetType planet;
  final ZodiacSign sign;
  final int house;
  final Dignity dignity;
  final int score;
  final String signBlurb;
  final String houseBlurb;
}

/// The Dasha-section summary at view time.
class DashaNote {
  const DashaNote({
    required this.mahaLord,
    required this.antarLord,
    required this.mahaBlurb,
    required this.antarBlurb,
    required this.mahaEnd,
    required this.antarEnd,
  });

  final PlanetType mahaLord;
  final PlanetType antarLord;
  final String mahaBlurb;
  final String antarBlurb;
  final DateTime mahaEnd;
  final DateTime antarEnd;
}

/// A single "what's active in transit right now" entry.
class TransitNote {
  const TransitNote({
    required this.transitPlanet,
    required this.natalHouse,
    required this.note,
    required this.weight,
  });

  final PlanetType transitPlanet;

  /// Natal-house position of the *transiting* planet (i.e. which bhava
  /// the transit planet is lighting up right now).
  final int natalHouse;

  final String note;

  /// Relative importance used to pick the top N highlights.
  final int weight;
}

/// Full report returned by [AnalysisEngine.compute].
class AnalysisReport {
  const AnalysisReport({
    required this.lagnaSign,
    required this.lagnaBlurb,
    required this.keyPlacements,
    required this.dashaNote,
    required this.transitHighlights,
  });

  final ZodiacSign lagnaSign;
  final String lagnaBlurb;
  final List<PlacementNote> keyPlacements;
  final DashaNote? dashaNote;
  final List<TransitNote> transitHighlights;
}

/// Pure-function analysis pipeline. Given the three primary chart bundles
/// (natal, dasha, transit) it produces an [AnalysisReport] suitable for
/// rendering and for feeding to the Apple Intelligence prompt as context.
abstract class AnalysisEngine {
  AnalysisEngine._();

  static AnalysisReport compute({
    required VedicChartData natal,
    DashaData? dasha,
    VedicChartData? transit,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now().toUtc();
    return AnalysisReport(
      lagnaSign: natal.ascendantSign,
      lagnaBlurb: kLagnaDescriptions[natal.ascendantSign] ?? '',
      keyPlacements: _topPlacements(natal),
      dashaNote: dasha == null ? null : _dashaNote(dasha, clock),
      transitHighlights:
          transit == null ? const [] : _transitHighlights(transit),
    );
  }

  // --------------------------------------------------------------------- KEY
  // Key-placement scoring. Each planet receives a composite score made up of
  // its dignity in the sign it occupies plus a house-placement bonus. The
  // top 5 scores are returned. Ties are broken by planet natural order
  // (Sun, Moon, Mars, ...).
  static List<PlacementNote> _topPlacements(VedicChartData natal) {
    final scored = <PlacementNote>[];
    for (final p in natal.planets) {
      final dignity = dignityOf(p.planet, p.sign);
      final score = dignity.score + housePlacementBonus(p.planet, p.house);
      scored.add(
        PlacementNote(
          planet: p.planet,
          sign: p.sign,
          house: p.house,
          dignity: dignity,
          score: score,
          signBlurb: kPlanetInSign[p.planet]?[p.sign] ?? '',
          houseBlurb: kPlanetInHouse[p.planet]?[p.house] ?? '',
        ),
      );
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.planet.index.compareTo(b.planet.index);
    });
    return scored.take(5).toList(growable: false);
  }

  // ------------------------------------------------------------------ DASHA
  static DashaNote _dashaNote(DashaData dasha, DateTime at) {
    final active = dasha.activeAt(at);
    return DashaNote(
      mahaLord: active.maha.planet,
      antarLord: active.antar.planet,
      mahaBlurb: kMahaDashaNarratives[active.maha.planet] ?? '',
      antarBlurb: kAntarDashaModifiers[active.antar.planet] ?? '',
      mahaEnd: active.maha.endDate,
      antarEnd: active.antar.endDate,
    );
  }

  // ------------------------------------------------------------------ TRANSIT
  // Weight each transiting planet by two considerations:
  //   1. How "slow" / karmically significant it is (Sa/Ra/Ke/Ju > Ma > Me/Ve
  //      > Su > Mo).
  //   2. How important the natal house it\'s sitting in is (kendra/trikona
  //      > upachaya > neutral > dusthana).
  // Top 3 weighted hits are returned.
  static List<TransitNote> _transitHighlights(VedicChartData transit) {
    final notes = <TransitNote>[];
    for (final p in transit.planets) {
      final weight = _planetWeight(p.planet) + _houseWeight(p.house);
      notes.add(
        TransitNote(
          transitPlanet: p.planet,
          natalHouse: p.house,
          note: kTransitNotes[p.planet]?[p.house] ?? '',
          weight: weight,
        ),
      );
    }
    notes.sort((a, b) => b.weight.compareTo(a.weight));
    return notes.take(3).toList(growable: false);
  }

  static int _planetWeight(PlanetType p) => switch (p) {
        PlanetType.saturn => 10,
        PlanetType.jupiter => 9,
        PlanetType.rahu => 8,
        PlanetType.ketu => 8,
        PlanetType.mars => 5,
        PlanetType.venus => 3,
        PlanetType.mercury => 3,
        PlanetType.sun => 3,
        PlanetType.moon => 1,
      };

  static int _houseWeight(int h) {
    if (isKendra(h) || isTrikona(h)) return 3;
    if (isUpachaya(h)) return 2;
    if (isDusthana(h)) return 0;
    return 1;
  }
}

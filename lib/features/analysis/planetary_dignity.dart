import '../../domain/models/enums.dart';

/// Classical Parashari dignity lookups — pure data, no state.
///
/// All references are to BPHS (Brihat Parashara Hora Shastra) and are the
/// tables universally agreed across Parashari tradition. Rahu / Ketu use
/// the most commonly accepted placements (Rahu exalted in Taurus, Ketu
/// exalted in Scorpio).

/// Classical dignity class for a planet in a sign.
enum Dignity {
  exalted,
  mooltrikona,
  ownSign,
  friendSign,
  neutralSign,
  enemySign,
  debilitated,
}

extension DignityLabel on Dignity {
  String get label => switch (this) {
        Dignity.exalted => 'Exalted',
        Dignity.mooltrikona => 'Mooltrikona',
        Dignity.ownSign => 'Own sign',
        Dignity.friendSign => 'Friend\'s sign',
        Dignity.neutralSign => 'Neutral',
        Dignity.enemySign => 'Enemy\'s sign',
        Dignity.debilitated => 'Debilitated',
      };

  /// Positive-is-strong score (−2..5).
  int get score => switch (this) {
        Dignity.exalted => 5,
        Dignity.mooltrikona => 4,
        Dignity.ownSign => 4,
        Dignity.friendSign => 3,
        Dignity.neutralSign => 2,
        Dignity.enemySign => 1,
        Dignity.debilitated => -2,
      };
}

/// Exaltation sign for each graha.
const Map<PlanetType, ZodiacSign> kExaltationSign = {
  PlanetType.sun: ZodiacSign.aries,
  PlanetType.moon: ZodiacSign.taurus,
  PlanetType.mars: ZodiacSign.capricorn,
  PlanetType.mercury: ZodiacSign.virgo,
  PlanetType.jupiter: ZodiacSign.cancer,
  PlanetType.venus: ZodiacSign.pisces,
  PlanetType.saturn: ZodiacSign.libra,
  PlanetType.rahu: ZodiacSign.taurus,
  PlanetType.ketu: ZodiacSign.scorpio,
};

/// Debilitation sign is exactly 7th from exaltation.
const Map<PlanetType, ZodiacSign> kDebilitationSign = {
  PlanetType.sun: ZodiacSign.libra,
  PlanetType.moon: ZodiacSign.scorpio,
  PlanetType.mars: ZodiacSign.cancer,
  PlanetType.mercury: ZodiacSign.pisces,
  PlanetType.jupiter: ZodiacSign.capricorn,
  PlanetType.venus: ZodiacSign.virgo,
  PlanetType.saturn: ZodiacSign.aries,
  PlanetType.rahu: ZodiacSign.scorpio,
  PlanetType.ketu: ZodiacSign.taurus,
};

/// Own sign(s). Includes mooltrikona.
const Map<PlanetType, Set<ZodiacSign>> kOwnSigns = {
  PlanetType.sun: {ZodiacSign.leo},
  PlanetType.moon: {ZodiacSign.cancer},
  PlanetType.mars: {ZodiacSign.aries, ZodiacSign.scorpio},
  PlanetType.mercury: {ZodiacSign.gemini, ZodiacSign.virgo},
  PlanetType.jupiter: {ZodiacSign.sagittarius, ZodiacSign.pisces},
  PlanetType.venus: {ZodiacSign.taurus, ZodiacSign.libra},
  PlanetType.saturn: {ZodiacSign.capricorn, ZodiacSign.aquarius},
  // Rahu/Ketu have no classical "own sign" — kept empty.
  PlanetType.rahu: {},
  PlanetType.ketu: {},
};

/// Mooltrikona sign (stricter than own sign — degree range matters in full
/// practice but this is the sign that contains the mooltrikona).
const Map<PlanetType, ZodiacSign> kMooltrikonaSign = {
  PlanetType.sun: ZodiacSign.leo,
  PlanetType.moon: ZodiacSign.taurus,
  PlanetType.mars: ZodiacSign.aries,
  PlanetType.mercury: ZodiacSign.virgo,
  PlanetType.jupiter: ZodiacSign.sagittarius,
  PlanetType.venus: ZodiacSign.libra,
  PlanetType.saturn: ZodiacSign.aquarius,
};

/// Natural friendship table (from BPHS). Entries in the Set are friends;
/// anything not in the friend set or the planet's own/enemy list is neutral.
const Map<PlanetType, Set<PlanetType>> kNaturalFriends = {
  PlanetType.sun: {PlanetType.moon, PlanetType.mars, PlanetType.jupiter},
  PlanetType.moon: {PlanetType.sun, PlanetType.mercury},
  PlanetType.mars: {PlanetType.sun, PlanetType.moon, PlanetType.jupiter},
  PlanetType.mercury: {PlanetType.sun, PlanetType.venus},
  PlanetType.jupiter: {PlanetType.sun, PlanetType.moon, PlanetType.mars},
  PlanetType.venus: {PlanetType.mercury, PlanetType.saturn},
  PlanetType.saturn: {PlanetType.mercury, PlanetType.venus},
  // Nodes: treat no natural friends (they take the dispositor's tone).
  PlanetType.rahu: {},
  PlanetType.ketu: {},
};

/// Natural enmity table.
const Map<PlanetType, Set<PlanetType>> kNaturalEnemies = {
  PlanetType.sun: {PlanetType.venus, PlanetType.saturn},
  PlanetType.moon: {},
  PlanetType.mars: {PlanetType.mercury},
  PlanetType.mercury: {PlanetType.moon},
  PlanetType.jupiter: {PlanetType.mercury, PlanetType.venus},
  PlanetType.venus: {PlanetType.sun, PlanetType.moon},
  PlanetType.saturn: {PlanetType.sun, PlanetType.moon, PlanetType.mars},
  PlanetType.rahu: {},
  PlanetType.ketu: {},
};

/// Sign lords used to resolve the ruler of a given sign for friend/enemy
/// comparisons. Rahu / Ketu intentionally omitted — non-lordship in
/// Parashari tradition.
const Map<ZodiacSign, PlanetType> kSignLord = {
  ZodiacSign.aries: PlanetType.mars,
  ZodiacSign.taurus: PlanetType.venus,
  ZodiacSign.gemini: PlanetType.mercury,
  ZodiacSign.cancer: PlanetType.moon,
  ZodiacSign.leo: PlanetType.sun,
  ZodiacSign.virgo: PlanetType.mercury,
  ZodiacSign.libra: PlanetType.venus,
  ZodiacSign.scorpio: PlanetType.mars,
  ZodiacSign.sagittarius: PlanetType.jupiter,
  ZodiacSign.capricorn: PlanetType.saturn,
  ZodiacSign.aquarius: PlanetType.saturn,
  ZodiacSign.pisces: PlanetType.jupiter,
};

/// Classical kendras (1, 4, 7, 10) — the "pillars" of the chart.
bool isKendra(int house) => house == 1 || house == 4 || house == 7 || house == 10;

/// Classical trikonas (1, 5, 9) — auspicious dharma / fortune houses.
bool isTrikona(int house) => house == 1 || house == 5 || house == 9;

/// Dusthanas (6, 8, 12) — challenging houses.
bool isDusthana(int house) => house == 6 || house == 8 || house == 12;

/// Upachayas (3, 6, 10, 11) — growth houses; favour malefics.
bool isUpachaya(int house) =>
    house == 3 || house == 6 || house == 10 || house == 11;

/// Natural benefic / malefic classification (simplified — Mercury becomes
/// benefic or malefic based on company, but for default scoring we treat it
/// benefic when not conjoined with malefics).
bool isNaturalBenefic(PlanetType p) =>
    p == PlanetType.jupiter ||
    p == PlanetType.venus ||
    p == PlanetType.moon ||
    p == PlanetType.mercury;

bool isNaturalMalefic(PlanetType p) =>
    p == PlanetType.sun ||
    p == PlanetType.mars ||
    p == PlanetType.saturn ||
    p == PlanetType.rahu ||
    p == PlanetType.ketu;

/// Resolve the dignity class of [planet] in [sign].
Dignity dignityOf(PlanetType planet, ZodiacSign sign) {
  if (kExaltationSign[planet] == sign) return Dignity.exalted;
  if (kDebilitationSign[planet] == sign) return Dignity.debilitated;
  if (kMooltrikonaSign[planet] == sign) return Dignity.mooltrikona;
  if ((kOwnSigns[planet] ?? const {}).contains(sign)) return Dignity.ownSign;
  final lord = kSignLord[sign];
  if (lord == null || planet == PlanetType.rahu || planet == PlanetType.ketu) {
    return Dignity.neutralSign;
  }
  if ((kNaturalFriends[planet] ?? const {}).contains(lord)) {
    return Dignity.friendSign;
  }
  if ((kNaturalEnemies[planet] ?? const {}).contains(lord)) {
    return Dignity.enemySign;
  }
  return Dignity.neutralSign;
}

/// House-placement bonus used by the analysis engine.
///
/// * Kendra (1, 4, 7, 10): +2
/// * Trikona (1, 5, 9) [+ further]: +2
/// * Upachaya + malefic: +1
/// * Dusthana (6, 8, 12) + benefic: −2
/// * Dusthana + malefic: 0 (malefics tolerate dusthanas)
int housePlacementBonus(PlanetType planet, int house) {
  var bonus = 0;
  if (isKendra(house)) bonus += 2;
  if (isTrikona(house)) bonus += 2;
  if (isUpachaya(house) && isNaturalMalefic(planet)) bonus += 1;
  if (isDusthana(house)) {
    bonus += isNaturalBenefic(planet) ? -2 : 0;
  }
  return bonus;
}

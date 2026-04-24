import '../../../domain/models/enums.dart';

/// Parashari gochara (transit) notes: transiting graha × natal bhava.
///
/// Transits activate the themes of the house they occupy, modulated by the
/// transiting planet\'s karakattvas. Slower planets (Saturn, Jupiter, Rahu,
/// Ketu) deliver the most visible, life-shaping effects; faster planets
/// (Sun, Mercury, Venus, Mars) modulate the background flow.
///
/// Classical notes used below:
/// * Saturn 12th/1st/2nd from natal Moon = **sade-sati** (7.5y)
/// * Jupiter transits ≈ 1 year per sign; Rahu/Ketu ≈ 1.5y per sign
/// * Upachaya houses (3, 6, 10, 11) welcome malefics
/// * Dusthanas (6, 8, 12) challenge benefics
const Map<PlanetType, Map<int, String>> kTransitNotes = {
  // --------------------------------------------------------------------- SUN
  PlanetType.sun: {
    1: 'Ego and vitality spotlighted; heart/spine health watch; identity '
        'assertion.',
    2: 'Finances, speech, and family illuminated; paternal themes.',
    3: 'Courage surges, sibling events, short-journey opportunities.',
    4: 'Home and mother themes confront; property matters surface.',
    5: 'Creative projects activate; children\'s affairs prominent.',
    6: 'Strong. Defeats enemies, wins competitions, health contests.',
    7: 'Partnership and public visibility; business dealings with authority.',
    8: 'Ego-dissolving events, occult themes, transformation pressure.',
    9: 'Dharmic opportunities, father focus, fortune peaks monthly.',
    10: 'Career-visibility peak; month for recognition and authority moves.',
    11: 'Strong. Income, gains, elder-sibling contact, goal fulfilment.',
    12: 'Expenses, retreat, foreign themes; ego quietens.',
  },

  // --------------------------------------------------------------------- MOON
  PlanetType.moon: {
    1: 'Mood colours identity; sensitivity heightened for ~2 days.',
    2: 'Emotional finances, food pleasures, family warmth.',
    3: 'Emotional courage, sibling calls, short travel whim.',
    4: 'Home peace or turmoil; strong mother-bond activity.',
    5: 'Romantic mood, children\'s attention, creative flow.',
    6: 'Anxiety possible; service pulled; minor health attention.',
    7: 'Partner-centric mood; public emotional face visible.',
    8: 'Intuition sharp, hidden feelings surface, dreams vivid.',
    9: 'Devotional mood, pilgrimage pull, dharmic reflection.',
    10: 'Public emotional display; reputation rides the mood.',
    11: 'Emotional gains, friend contact, nurturing network.',
    12: 'Sleep, retreat, emotional dissolution, bed-pleasures.',
  },

  // --------------------------------------------------------------------- MARS
  PlanetType.mars: {
    1: 'Aggression and accident-proneness rise; athletic push; impatience.',
    2: 'Harsh speech episodes, financial risk, family flare-ups.',
    3: 'Excellent. Bold action, decisive efforts, upachaya-favoured.',
    4: 'Home disputes, property friction, maternal tension.',
    5: 'Passionate romance, speculation temptation, child conflicts.',
    6: 'Excellent. Wins legal / competitive battles, heals through exertion.',
    7: 'Partnership conflict, marriage friction, manglik-like tension.',
    8: 'Surgery, accidents, occult intensity, transformation pressure.',
    9: 'Religious disputes, father conflict, adventurous travel.',
    10: 'Career aggression, decisive authority moves, confrontations.',
    11: 'Excellent. Ambitious gains, achievement push, elder-sibling action.',
    12: 'Hidden anger, expenses on conflicts, disturbed sleep, foreign risk.',
  },

  // ------------------------------------------------------------------ MERCURY
  PlanetType.mercury: {
    1: 'Mental clarity, communication bursts, writing opportunities.',
    2: 'Financial negotiations, family deals, speech clarity.',
    3: 'Writing, trade, siblings, short-journey peaks.',
    4: 'Home contracts, educational moves, mother\'s communication.',
    5: 'Creative writing, children\'s learning, speculation cleverness.',
    6: 'Legal disputes, medical queries, mental-health attention.',
    7: 'Business partnerships, diplomatic deals, intellectual meetings.',
    8: 'Research peaks, occult study, secretive communication.',
    9: 'Teaching opportunities, scholarly dharma, father\'s letters.',
    10: 'Career communication, media attention, articulate public roles.',
    11: 'Networking gains, trading income, intellectual friend activity.',
    12: 'Hidden study, foreign correspondence, quiet research retreat.',
  },

  // ------------------------------------------------------------------ JUPITER
  PlanetType.jupiter: {
    1: 'Wisdom and dharma expand; teacher may appear; personal growth year.',
    2: 'Wealth, family expansion, sweet speech, learning gains.',
    3: 'Courage through wisdom, supportive siblings, dharmic writing.',
    4: 'Home peace, real-estate expansion, mother\'s wellbeing, classical '
        'kutumba-vriddhi.',
    5: 'Children news or creative breakthrough; poorvapunya ripens.',
    6: 'Legal victories and health wisdom, but Jupiter in dusthana\'s grace '
        'is diminished.',
    7: 'Marriage or partnership expansion; wise spouse contact.',
    8: 'Inheritance, occult wisdom, grace in difficulty. A silver lining.',
    9: 'Classical peak. Guru\'s grace, fortune, pilgrimage, flourishing '
        'dharma.',
    10: 'Career dharma, teaching/counselling, public wisdom; raja-yoga '
        'window.',
    11: 'Classical great gains. Income, desires fulfilled, network '
        'expansion.',
    12: 'Charitable expenditure, spiritual retreat, foreign dharma, moksha '
        'progress.',
  },

  // -------------------------------------------------------------------- VENUS
  PlanetType.venus: {
    1: 'Charm peaks, self-care, aesthetic self-presentation.',
    2: 'Wealth through arts/luxuries, sweet speech, family harmony.',
    3: 'Artistic siblings, creative writing, romantic short travel.',
    4: 'Home beautification, mother-joy, vehicle purchases.',
    5: 'Romance, creative output, children\'s joy, artistic bloom.',
    6: 'Relationship conflict, pleasure-organ issues, service through beauty.',
    7: 'Marriage, attraction, partnership luxuries, classical kalatra.',
    8: 'Hidden romance, sensual transformations, spouse inheritance.',
    9: 'Dharma through arts, refined travel, luxurious pilgrimage.',
    10: 'Artistic career peak, luxury business, diplomatic recognition.',
    11: 'Gains through arts, luxury friends, desire fulfilment.',
    12: 'Secret pleasures, foreign romance, artistic retreat. Classically '
        'good here.',
  },

  // ------------------------------------------------------------------- SATURN
  PlanetType.saturn: {
    1: 'Sade-sati midpoint. Identity tests, health discipline, serious '
        'years ahead.',
    2: 'Sade-sati exit. Financial discipline, family strain, careful '
        'speech.',
    3: 'Strong upachaya. Persistence rewarded, siblings mature, efforts '
        'compound.',
    4: 'Home cold, mother concerns, real-estate freezes, emotional '
        'austerity.',
    5: 'Children concerns, creative blocks, speculation losses, intellect '
        'sobered.',
    6: 'Strong. Slow defeat of enemies; chronic illness resolves through '
        'discipline.',
    7: 'Marriage tests, older spouse enters, partnership delays.',
    8: 'Longevity tests, chronic conditions, occult discipline, slow '
        'transformation.',
    9: 'Dharmic tests, father distance, traditional religion tightens.',
    10: 'Classical career peak. Slow ascent, late success, executive '
        'position.',
    11: 'Strong. Great gains after delay, senior friends, structured '
        'income.',
    12: 'Sade-sati onset. Retreat, expenses, foreign service, monastic '
        'pulls.',
  },

  // --------------------------------------------------------------------- RAHU
  PlanetType.rahu: {
    1: 'Identity upheaval, foreign recognition, unusual self-presentation.',
    2: 'Unusual wealth sources, foreign income, family secrets surface.',
    3: 'Ambitious courage, tech-savvy siblings, viral communication.',
    4: 'Foreign residence, unusual home changes, mother karma activates.',
    5: 'Unusual children matters, foreign romance, speculation themes.',
    6: 'Strong. Defeats enemies through unconventional means, legal wins.',
    7: 'Foreign or unusual spouse, partnership obsession, marriage intensity.',
    8: 'Occult intensification, inheritance intrigue, hidden '
        'transformations.',
    9: 'Unconventional dharma, foreign teachers, questioning of tradition.',
    10: 'Ambitious career moves, foreign opportunity, viral public rise.',
    11: 'Rahu\'s best transit. Huge gains, ambitious network, desire '
        'fulfilment.',
    12: 'Foreign settlement, addiction risk, hidden dealings, spiritual '
        'illusion.',
  },

  // --------------------------------------------------------------------- KETU
  PlanetType.ketu: {
    1: 'Identity dissolution, spiritual insight, past-life memory stirs.',
    2: 'Detachment from wealth, family distance, brief/cryptic speech.',
    3: 'Silent courage, sibling detachment, solo journeys.',
    4: 'Home instability, mother distance, emotional retreat.',
    5: 'Detachment from children, mystical creativity, past-life intellect.',
    6: 'Strong. Sudden enemy defeats, disease through detachment.',
    7: 'Marriage detachment, spiritual spouse, partnership transforming or '
        'ending.',
    8: 'Occult mastery, sudden transformations, mystical events.',
    9: 'Spiritual dharma, detachment from formal religion, inner guru rises.',
    10: 'Career detachment, unconventional authority, fame without '
        'attachment.',
    11: 'Few but deep friends, moksha-oriented gains, restrained income.',
    12: 'Natural moksha placement, spiritual retreat, monastic pull.',
  },
};

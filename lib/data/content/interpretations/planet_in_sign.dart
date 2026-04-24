import '../../../domain/models/enums.dart';

/// Parashari planet-in-sign interpretations.
///
/// Each entry is a single-sentence characterisation rooted in the planet's
/// classical dignity (exaltation / own sign / debilitation) and the sign's
/// element and modality. Rahu/Ketu use the commonly-accepted Parashari
/// placements (Rahu exalted Taurus / debilitated Scorpio, Ketu reversed).
///
/// Read as "{planet} in {sign}: {note}". The result plugs into the Analysis
/// screen and is also fed to the Apple Intelligence prompt as context.
const Map<PlanetType, Map<ZodiacSign, String>> kPlanetInSign = {
  // --------------------------------------------------------------------- SUN
  PlanetType.sun: {
    ZodiacSign.aries:
        'Exalted. Self-assured authority and pioneering will; the classical '
        'raja-yoga placement for leadership when well-aspected.',
    ZodiacSign.taurus:
        'Authority expressed through resources, stability, and persistence; '
        'slower to assert but durable once established.',
    ZodiacSign.gemini:
        'Intellectual ego; identity through speech, writing, or trade. '
        'Curiosity-driven sense of self.',
    ZodiacSign.cancer:
        'Emotional authority; rules through empathy and the home. Soft power '
        'with a deep protective streak.',
    ZodiacSign.leo:
        'Own sign and mooltrikona. Classical kingship. Dignified, creative, '
        'generous. The Sun\'s most natural expression.',
    ZodiacSign.virgo:
        'Precise, service-oriented ego; authority exercised through detail, '
        'discrimination, and competence.',
    ZodiacSign.libra:
        'Debilitated. Identity diluted through others; indecision in self-'
        'direction. Needs neecha-bhanga to flourish.',
    ZodiacSign.scorpio:
        'Intense, controlled authority. The Sun burns underground here. '
        'Powerful, investigative, but often secretive.',
    ZodiacSign.sagittarius:
        'Dharma-aligned ego; principled leadership, teaching, or law. '
        'Authority carried with philosophical weight.',
    ZodiacSign.capricorn:
        'Hierarchical, system-respecting ego; slow but durable rise through '
        'structure and earned position.',
    ZodiacSign.aquarius:
        'Reformist ego; leads through networks and causes rather than '
        'personal authority. Humanitarian tint.',
    ZodiacSign.pisces:
        'Devotional ego that dissolves in service; authority through '
        'compassion. Boundary issues are the classical risk.',
  },

  // --------------------------------------------------------------------- MOON
  PlanetType.moon: {
    ZodiacSign.aries:
        'Impulsive, quick-reacting mind; moods flare and pass rapidly. '
        'Courageous but short-fused.',
    ZodiacSign.taurus:
        'Exalted. Emotionally anchored, sensual, comfort-seeking. Strong '
        'rapport with the public; Moon\'s happiest seat.',
    ZodiacSign.gemini:
        'Curious, restless, information-fed mind. Emotional wellbeing tied '
        'to mental stimulation.',
    ZodiacSign.cancer:
        'Own sign. Deep intuition, maternal nature, receptive mind. '
        'Classical best placement for emotional intelligence.',
    ZodiacSign.leo:
        'Proud emotional nature; needs recognition and warmth. Heart-centred '
        'but vulnerable to slights.',
    ZodiacSign.virgo:
        'Worry-prone mind; emotional wellbeing tied to order, hygiene, and '
        'health. Over-analysis of feelings.',
    ZodiacSign.libra:
        'Partner-oriented feelings; peace of mind depends on balance and '
        'beauty in the environment.',
    ZodiacSign.scorpio:
        'Debilitated. Emotional intensity, secrecy, transformation through '
        'upheaval. Mind rarely at rest.',
    ZodiacSign.sagittarius:
        'Optimistic, philosophy-seeking mind. Travel and higher learning '
        'soothe; dogma irritates.',
    ZodiacSign.capricorn:
        'Restrained, duty-oriented emotional nature; warmth takes time to '
        'surface. Lonely in youth, stable later.',
    ZodiacSign.aquarius:
        'Detached, idea-oriented feelings; processes emotion intellectually. '
        'Group belonging matters more than family.',
    ZodiacSign.pisces:
        'Boundless, dreamy, imagination-rich mind; porous to others\' moods. '
        'Mystical or escapist by turns.',
  },

  // --------------------------------------------------------------------- MARS
  PlanetType.mars: {
    ZodiacSign.aries:
        'Own sign, mooltrikona. Direct, courageous, pioneering action. The '
        'classical warrior placement.',
    ZodiacSign.taurus:
        'Slow, resource-guarding aggression; fights only for what is owned. '
        'Patience masks tenacity.',
    ZodiacSign.gemini:
        'Mental combat, sharp arguments, nervous energy. Aggression '
        'channelled through speech.',
    ZodiacSign.cancer:
        'Debilitated. Emotionally-driven anger; reactive and protective '
        'rather than strategic.',
    ZodiacSign.leo:
        'Dramatic, authoritative action; fights for pride and territory. '
        'Loud but honourable.',
    ZodiacSign.virgo:
        'Surgical, critical action; fights through detail and method. Good '
        'for engineers, surgeons, auditors.',
    ZodiacSign.libra:
        'Diplomatic Mars. Passion routed through partnership; conflict '
        'avoided until the breaking point, then decisive.',
    ZodiacSign.scorpio:
        'Own sign. Penetrating, strategic, transformative. Classical '
        'placement for covert operations and intense will.',
    ZodiacSign.sagittarius:
        'Righteous Mars. Fights for principle, faith, or higher cause. '
        'Crusader energy, for better and worse.',
    ZodiacSign.capricorn:
        'Exalted. Disciplined campaign-running and executive endurance. '
        'Mars\'s most productive seat.',
    ZodiacSign.aquarius:
        'Collective Mars. Action through networks, reform movements, '
        'systems change. Impersonal fight.',
    ZodiacSign.pisces:
        'Dissolving Mars. Aggression diffused, action through compassion '
        'or imagination. Can be passive-aggressive.',
  },

  // ------------------------------------------------------------------ MERCURY
  PlanetType.mercury: {
    ZodiacSign.aries:
        'Quick-thinking, impulsive speech, sharp-tongued. Ideas fire before '
        'they finish forming.',
    ZodiacSign.taurus:
        'Practical, materially-oriented mind; slow but thorough. Speech '
        'considered and often valuable.',
    ZodiacSign.gemini:
        'Own sign. Versatile, communicative, information-juggling. '
        'Mercury\'s natural airy home.',
    ZodiacSign.cancer:
        'Emotional intellect; memory-driven, intuitive speech. Mind coloured '
        'by family and mood.',
    ZodiacSign.leo:
        'Dramatic, authoritative speech; performative intellect. Ideas '
        'delivered with flair.',
    ZodiacSign.virgo:
        'Own sign, exalted, mooltrikona. Analytical, discriminating, '
        'precise. Classical genius placement.',
    ZodiacSign.libra:
        'Diplomatic mind, relationship-oriented communication, '
        'balance-seeking speech.',
    ZodiacSign.scorpio:
        'Investigative, secretive, penetrating intellect. Good for research, '
        'intelligence, forensic work.',
    ZodiacSign.sagittarius:
        'Big-picture mind; philosophical speech, sometimes imprecise on '
        'detail. Preacher rather than editor.',
    ZodiacSign.capricorn:
        'Disciplined intellect, executive communication, results-focused. '
        'Strategic and terse.',
    ZodiacSign.aquarius:
        'Innovative, systems-thinking, unconventional mind. Excellent for '
        'engineering, coding, abstract theory.',
    ZodiacSign.pisces:
        'Debilitated. Imaginative but imprecise; poetic mind, scattered '
        'logic. Needs structure to produce.',
  },

  // ------------------------------------------------------------------ JUPITER
  PlanetType.jupiter: {
    ZodiacSign.aries:
        'Bold dharma, leadership-oriented wisdom, action-driven expansion. '
        'Pioneer-priest archetype.',
    ZodiacSign.taurus:
        'Worldly wisdom, wealth and aesthetics, stable teaching. Jupiter '
        'anchored in the material.',
    ZodiacSign.gemini:
        'Intellectual teaching, multiplicity of interests. Breadth risks '
        'shallowness without focus.',
    ZodiacSign.cancer:
        'Exalted. Devotional wisdom, guru\'s grace, maternal dharma. '
        'Classical peak of Jupiter.',
    ZodiacSign.leo:
        'Royal dharma, creative wisdom, generous authority. Guru to the '
        'king. Or the king as guru.',
    ZodiacSign.virgo:
        'Critical wisdom; teaches through detail and method. Jupiter\'s '
        'natural expansiveness shrinks under Virgo\'s precision.',
    ZodiacSign.libra:
        'Diplomatic dharma, partnership wisdom, aesthetic philosophy. Law '
        'and mediation flourish.',
    ZodiacSign.scorpio:
        'Transformative wisdom, occult knowledge, depth teaching. Jupiter '
        'illuminating hidden terrain.',
    ZodiacSign.sagittarius:
        'Own sign, mooltrikona. The classical teacher. Expansive, '
        'principled, travel-oriented.',
    ZodiacSign.capricorn:
        'Debilitated. Dharma reduced to duty; wisdom constrained by '
        'cynicism or narrow materialism.',
    ZodiacSign.aquarius:
        'Reform-oriented wisdom, collective dharma, unconventional teaching. '
        'Jupiter as social architect.',
    ZodiacSign.pisces:
        'Own sign. Devotional, compassionate, spiritually-oriented wisdom. '
        'Mystical Jupiter at its most porous.',
  },

  // -------------------------------------------------------------------- VENUS
  PlanetType.venus: {
    ZodiacSign.aries:
        'Assertive love, quick attachments, passion over patience. Romance '
        'as conquest.',
    ZodiacSign.taurus:
        'Own sign, mooltrikona. Sensual, stable, wealth-accumulating, '
        'pleasure-rich. Venus\'s easiest seat.',
    ZodiacSign.gemini:
        'Playful, communicative affection; variety-seeking in love. '
        'Multiple connections common.',
    ZodiacSign.cancer:
        'Nurturing, emotionally-rooted love; family-centred desires. '
        'Affection expressed through care and food.',
    ZodiacSign.leo:
        'Dramatic, generous affection; romantic flair. Love on a stage, '
        'with applause expected.',
    ZodiacSign.virgo:
        'Debilitated. Critical in love, perfectionism in aesthetics. Service '
        'substitutes for affection.',
    ZodiacSign.libra:
        'Own sign. Harmonious partnership, balanced aesthetics, diplomatic '
        'love. Fair and refined.',
    ZodiacSign.scorpio:
        'Intense, possessive, transformative love; all-or-nothing. Jealousy '
        'and passion twinned.',
    ZodiacSign.sagittarius:
        'Idealistic, philosophical love; drawn to distant or foreign '
        'partners. Love as shared quest.',
    ZodiacSign.capricorn:
        'Pragmatic affection, duty-based partnership; stability over '
        'romance. Love matures late.',
    ZodiacSign.aquarius:
        'Unconventional love, platonic-affection blur, group-oriented. '
        'Independence non-negotiable.',
    ZodiacSign.pisces:
        'Exalted. Devotional, self-sacrificing, mystical love. Classical '
        'peak. Love as spiritual path.',
  },

  // ------------------------------------------------------------------- SATURN
  PlanetType.saturn: {
    ZodiacSign.aries:
        'Debilitated. Frustrated will, slow starts, delayed courage. '
        'Neecha-bhanga yoga from well-placed Mars can rescue.',
    ZodiacSign.taurus:
        'Patient Saturn; wealth through slow accumulation. Work and endurance '
        'the quiet strengths.',
    ZodiacSign.gemini:
        'Structured intellect, disciplined communication, careful speech. '
        'Good for technical writing and research.',
    ZodiacSign.cancer:
        'Emotional restraint, duty-bound home life; distant or demanding '
        'maternal figure is classical.',
    ZodiacSign.leo:
        'Restrained ego, late or reluctant authority. Pride humbled by '
        'Saturn\'s discipline.',
    ZodiacSign.virgo:
        'Disciplined analysis, methodical service, painstaking craft. '
        'Perfectionist Saturn.',
    ZodiacSign.libra:
        'Exalted. Judicial Saturn. Balanced long-view, classical "supreme '
        'judge" placement.',
    ZodiacSign.scorpio:
        'Hidden Saturn; long transformations, secretive discipline. Tests '
        'come underground.',
    ZodiacSign.sagittarius:
        'Philosophical Saturn; disciplined dharma, teaching through '
        'struggle. Slow wisdom.',
    ZodiacSign.capricorn:
        'Own sign. Executive Saturn. Classical ambition, structure-building, '
        'steady rise through hierarchy.',
    ZodiacSign.aquarius:
        'Own sign, mooltrikona. Reform Saturn. Systems-building, '
        'humanitarian discipline, group-focused.',
    ZodiacSign.pisces:
        'Dissolving Saturn; spiritual tests through disillusionment. Hidden '
        'service, retreat, or renunciation.',
  },

  // --------------------------------------------------------------------- RAHU
  PlanetType.rahu: {
    ZodiacSign.aries:
        'Aggressive ambition, impulsive chase for recognition. Desire '
        'outruns patience.',
    ZodiacSign.taurus:
        'Exalted (commonly accepted). Amplified material desires channelled '
        'productively; wealth-and-comfort obsession.',
    ZodiacSign.gemini:
        'Information hunger, media obsession, shape-shifting communication. '
        'Viral-message Rahu.',
    ZodiacSign.cancer:
        'Emotional obsession, unusual family patterns, foreign-origin '
        'nurturing. Karmic home upheaval.',
    ZodiacSign.leo:
        'Fame hunger, dramatic self-obsession, hunger for authority. Rahu '
        'loves Leo\'s stage.',
    ZodiacSign.virgo:
        'Obsessive analysis, health-fixation, unusual work modes. Some '
        'schools call this own sign for Rahu.',
    ZodiacSign.libra:
        'Partnership obsession, unusual relationships, ambitious diplomacy. '
        'Transactional love.',
    ZodiacSign.scorpio:
        'Debilitated (commonly accepted). Obsession meets its own element '
        'intense, can overheat into paranoia.',
    ZodiacSign.sagittarius:
        'Philosophy obsession, foreign teachers, unconventional faith. '
        'Spiritual hunger with pitfalls.',
    ZodiacSign.capricorn:
        'Careerism, authority-hunger, political ambition. Rahu climbs the '
        'Saturnine hierarchy obsessively.',
    ZodiacSign.aquarius:
        'Tech and network obsession, futurist; natural fit with Saturn\'s '
        'reform bent. Viral innovation.',
    ZodiacSign.pisces:
        'Spiritual obsession, escapism, mystical illusion. Addiction risk '
        'on the shadow side.',
  },

  // --------------------------------------------------------------------- KETU
  PlanetType.ketu: {
    ZodiacSign.aries:
        'Detachment from fighting; past-life warrior with current '
        'disinterest in conflict.',
    ZodiacSign.taurus:
        'Debilitated (commonly accepted). Detachment from wealth and '
        'comfort; material renunciation.',
    ZodiacSign.gemini:
        'Detachment from information and chatter; silent intellect, few '
        'but deep words.',
    ZodiacSign.cancer:
        'Emotional detachment; distant from family, inward retreat. Mother '
        'karma often unresolved.',
    ZodiacSign.leo:
        'Detachment from ego and recognition; quiet authority, reluctant '
        'leadership.',
    ZodiacSign.virgo:
        'Detachment from detail; intuitive rather than analytical service. '
        'Spiritual physician archetype.',
    ZodiacSign.libra:
        'Detachment from partnership; solitary by karmic pattern. Solo '
        'dharma after past-life pairings.',
    ZodiacSign.scorpio:
        'Exalted (commonly accepted). Detachment meets depth. Natural '
        'mystic, occult aptitude, moksha-seeker.',
    ZodiacSign.sagittarius:
        'Detachment from dharma-as-institution; inner spiritual path rather '
        'than formal tradition.',
    ZodiacSign.capricorn:
        'Detachment from careerism; quiet executive, reluctant climber. '
        'Duty without ambition.',
    ZodiacSign.aquarius:
        'Detachment from groups; solitary reformer, prefers ideas to '
        'movements.',
    ZodiacSign.pisces:
        'Natural moksha placement; spiritual dissolution, mystical '
        'orientation. Ketu\'s home ground.',
  },
};

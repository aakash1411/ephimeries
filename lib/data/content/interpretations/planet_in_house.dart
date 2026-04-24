import '../../../domain/models/enums.dart';

/// Parashari planet-in-house (bhava) interpretations.
///
/// Keyed by (planet, 1-based house number 1..12). Each entry is a compact
/// characterisation drawing on classical BPHS principles:
///
/// * Kendras (1, 4, 7, 10). Strong, direction-giving houses
/// * Trikonas (1, 5, 9). Auspicious, dharma/poorvapunya houses
/// * Dusthanas (6, 8, 12). Challenging, transformational
/// * Upachayas (3, 6, 10, 11). Grow stronger over time, favour malefics
/// * Dig-bala. Specific planets strongest in specific kendras
///   (Sun & Mars in 10, Jupiter & Mercury in 1, Moon & Venus in 4, Saturn in 7)
const Map<PlanetType, Map<int, String>> kPlanetInHouse = {
  // --------------------------------------------------------------------- SUN
  PlanetType.sun: {
    1: 'Leadership traits etched into personality; strong vitality, commanding '
        'presence, paternal authority visible in the bearing. Ego prominent.',
    2: 'Wealth linked to authority or government; father\'s lineage shapes '
        'finances; speech can be harsh or decisive.',
    3: 'Excellent. Strong courage, drive, and short-journey success. Upachaya '
        'house loves the Sun; younger sibling rivalry classical.',
    4: 'Weak dig-bala. Emotional foundation strained, distant or authoritarian '
        'mother, friction over home or real estate.',
    5: 'Creative authority, leadership through intelligence, dharmic children. '
        'Delays in the first child\'s arrival are classical.',
    6: 'Strong in upachaya dusthana. Defeats enemies, excels in government, '
        'law, and competitive fields.',
    7: 'Proud or authoritative spouse; partnerships with officials; ego '
        'tension in marriage unless Sun is well-aspected.',
    8: 'Health concerns around heart, bones, vitality; transformations come '
        'through ego-dissolution; hidden inheritance from father.',
    9: 'Excellent. Strong dharma, fortunate father, traditional religion, '
        'guru\'s recognition. Classic bhagya-lift.',
    10: 'Dig-bala. The Sun\'s crown seat. Public authority, professional '
        'eminence, raja-yoga potential. Career is the life-theme.',
    11: 'Powerful gains through authority; influential friends; income through '
        'leadership or government.',
    12: 'Weakened ego, expenditure on authority, foreign residence, hidden or '
        'absent father. Spiritual ego-dissolution possible.',
  },

  // --------------------------------------------------------------------- MOON
  PlanetType.moon: {
    1: 'Emotional personality, attractive face, moods visible on the surface. '
        'Mind and identity fused; public-facing nature.',
    2: 'Wealth flows with emotional cycles; close family bonds; sweet speech; '
        'fluctuating finances are classical.',
    3: 'Courage colored by emotion; close to sisters; frequent short journeys; '
        'communication responsive rather than strategic.',
    4: 'Dig-bala. Moon\'s happiest placement. Strong emotional foundation, '
        'happy home, close mother, inner peace (chandra-mangala rules willing).',
    5: 'Creative mind, love of children, strong memory, emotional intelligence. '
        'Good for artists, writers, teachers.',
    6: 'Anxiety, digestive or mental health watchouts; service to others; debts '
        'can fluctuate. A difficult seat for the Moon.',
    7: 'Emotionally-needy partnerships; popular, public-facing spouse; marriage '
        'tied to emotional ups and downs.',
    8: 'Emotional upheavals, hidden fears, strong intuition, occult aptitude. '
        'The Moon is uncomfortable here but gains depth.',
    9: 'Devotional, dharmic mother, guru\'s grace, emotional bond to tradition '
        'and pilgrimage.',
    10: 'Public career, popularity, fluctuating fame; mother\'s influence on '
        'career; good for public-facing professions.',
    11: 'Emotional gains, many friends, nurturing network, income through '
        'public or caring professions.',
    12: 'Rich dream-life, emotional retreat, foreign lands, bed-pleasures. '
        'Moksha-leaning emotional life.',
  },

  // --------------------------------------------------------------------- MARS
  PlanetType.mars: {
    1: 'Assertive, athletic, hot-tempered; scars or injuries classical. '
        'Kuja-dosha (manglik) consideration for marriage.',
    2: 'Harsh speech, family conflict, volatile finances. Mars can make or '
        'break wealth through aggressive ventures.',
    3: 'Excellent. Mars\'s favourite upachaya. Bold, courageous, strong '
        'siblings, successful short journeys.',
    4: 'Home disputes, property struggles; aggressive or absent mother; '
        'emotional volatility beneath the surface.',
    5: 'Creative fire, passionate romance; few or delayed children; miscarriage '
        'concerns classical. Speculation risk.',
    6: 'Excellent. Destroys enemies, overcomes debts, strong in competition, '
        'litigation, sport, military.',
    7: 'Manglik placement. Relationship friction, dominating spouse, '
        'marriage delays or multiple unions.',
    8: 'Surgery, accidents, longevity tests; hidden wealth; occult and '
        'investigation flourish.',
    9: 'Aggressive dharma, conflict with father or guru; strong convictions '
        'but argumentative religion.',
    10: 'Dig-bala. Mars\'s executive peak. Military, police, surgery, '
        'engineering, decisive leadership.',
    11: 'Aggressive gains, strong ambition; elder-sibling conflicts but '
        'eventual gains through them.',
    12: 'Hidden anger, expenditure on conflicts, foreign military or surgical '
        'career, sleep disturbed.',
  },

  // ------------------------------------------------------------------ MERCURY
  PlanetType.mercury: {
    1: 'Dig-bala. Intelligent, youthful appearance, good communicator, '
        'curious mind; identity through intellect.',
    2: 'Excellent. Wealth through speech and trade, family of intellectuals, '
        'sweet and precise speech.',
    3: 'Writers, traders, networkers; strong sibling bonds; short journeys '
        'frequent and fruitful.',
    4: 'Educated mother, good early education, vehicles acquired through '
        'trade or communication work.',
    5: 'Intellectual creativity, clever children, speculation interest, '
        'strong teaching aptitude.',
    6: 'Conflicts through speech or writing; mental-health watchouts; legal '
        'disputes through contracts.',
    7: 'Intellectual spouse, business partnerships, diplomatic marriage; '
        'younger or peer-age partner.',
    8: 'Research, investigation, occult learning; hidden intelligence, '
        'writing under pseudonym.',
    9: 'Scholarly dharma, educated father, publishing; strong for teachers '
        'and philosophers.',
    10: 'Communication career. Writer, trader, diplomat, analyst. Articulate '
        'profession with public voice.',
    11: 'Gains through communication, trading, networking; wide circle of '
        'friends, intellectual income.',
    12: 'Hidden study, foreign-language aptitude, writing in retreat, '
        'contemplative intelligence.',
  },

  // ------------------------------------------------------------------ JUPITER
  PlanetType.jupiter: {
    1: 'Dig-bala. Wisdom, dharma, noble personality. Physical and moral '
        'weight; guru-like presence.',
    2: 'Excellent. Wealth, good family, sweet truthful speech, traditional '
        'values. Dhana-yoga seed.',
    3: 'Wisdom in action; supportive elder siblings; but Jupiter\'s expansion '
        'mildly shrinks courage.',
    4: 'Happy home, learned mother, real estate gains, dharmic foundation. '
        'Classical hamsa-like domestic peace.',
    5: 'Excellent. Wise children, strong poorvapunya (past-life merit), '
        'teaching aptitude, creative wisdom.',
    6: 'Service-oriented, legal wisdom, but Jupiter diminishes in a '
        'dusthana. Health of liver/pancreas watch.',
    7: 'Wise spouse, dharmic marriage, ethical partnerships; foreign or '
        'older spouse common.',
    8: 'Hidden wisdom, long life, inheritance, occult study. Jupiter gives '
        'grace in crisis here.',
    9: 'Own house. Dharma, guru, father, fortune all amplified. The '
        'classical bhagya-sthana at peak.',
    10: 'Dharmic career. Teaching, law, counselling. Raja-yoga via '
        'kendra-trikona relationship.',
    11: 'Excellent. Great gains, large social circle, fulfilled desires. '
        'Jupiter loves labha-bhava.',
    12: 'Charitable expenditure, spiritual retreat, foreign teaching, '
        'ashram life. Moksha-friendly.',
  },

  // -------------------------------------------------------------------- VENUS
  PlanetType.venus: {
    1: 'Attractive appearance, artistic disposition, pleasure-seeking, '
        'charming; personality through beauty.',
    2: 'Wealth through arts and luxuries; sweet speech, refined family, '
        'good food. Dhana-yoga ally.',
    3: 'Artistic siblings, creative courage, writing and music talents; '
        'pleasant short journeys.',
    4: 'Dig-bala. Luxurious home, vehicles, happy mother, aesthetic '
        'environment. Venus at peak domesticity.',
    5: 'Romantic creativity, love of arts, beautiful children, romance-rich '
        'life; good for performers.',
    6: 'Relationship conflicts, diseases of reproductive/urinary system, '
        'service through arts or beauty.',
    7: 'Strong attraction, beautiful spouse, happy marriage, partnership '
        'luxuries. Classical kalatra-karaka home.',
    8: 'Hidden romance, inheritance from spouse, secret wealth, sensual '
        'mysteries. Tantra/occult arts.',
    9: 'Dharma through arts, foreign fortune, refined father, luxurious '
        'travel and pilgrimage.',
    10: 'Artistic career, luxury industry, diplomacy, entertainment, '
        'fashion. Public-facing beauty.',
    11: 'Excellent. Gains through arts, luxury friends, fulfilment of '
        'desires. Classical wealth-and-love yoga.',
    12: 'Bed-pleasures (classically auspicious here!), foreign romance, '
        'artistic retreat; malavya-like charm.',
  },

  // ------------------------------------------------------------------- SATURN
  PlanetType.saturn: {
    1: 'Serious appearance, delayed maturity, melancholic youth; tall, lean '
        'build; heavy sense of responsibility from early on.',
    2: 'Delayed wealth, family duties, restrained or harsh speech, '
        'late-life accumulation.',
    3: 'Excellent upachaya. Persistence, disciplined effort; elder siblings '
        'often difficult but teach resilience.',
    4: 'Cold home, distant mother, real-estate delays, emotional austerity. '
        'Sukha (happiness) bhava under strain.',
    5: 'Delayed children, serious-minded creativity, disciplined intellect; '
        'teaches through adversity.',
    6: 'Excellent. Steady overcoming of enemies, work through service, '
        'disciplined competition.',
    7: 'Dig-bala. Delayed marriage, older spouse, duty-based partnership, '
        'long-lasting union after the wait.',
    8: 'Long life, chronic conditions, slow transformations, occult study; '
        'Saturn\'s patience in Randhra.',
    9: 'Austere dharma, distant father, traditional religion practised '
        'through discipline rather than devotion.',
    10: 'Classical career summit. Slow ascent to executive position, '
        'hierarchical authority, late success.',
    11: 'Excellent. Large gains after delay, senior friends, long-term '
        'structured income. Saturn loves labha.',
    12: 'Retreat, monastic tendencies, foreign service, expenses on duty '
        'and obligation.',
  },

  // --------------------------------------------------------------------- RAHU
  PlanetType.rahu: {
    1: 'Unconventional personality, foreign recognition, ambitious identity; '
        'shape-shifting self-presentation.',
    2: 'Unusual wealth sources, foreign income, speech quirks, possible '
        'family scandals or secrets.',
    3: 'Strong upachaya. Ambitious effort, tech-savvy siblings, risk-taking '
        'courage; viral communication.',
    4: 'Unusual home, foreign residence, distant or unusual mother, property '
        'schemes of ambition.',
    5: 'Unconventional creativity, speculation, unusual children, romance '
        'with foreigners or across social lines.',
    6: 'Excellent. Defeats enemies through unconventional means, overcomes '
        'debts, good for litigation and research.',
    7: 'Foreign or unconventional spouse, partnership obsession, intense '
        'marriage with transactional undertones.',
    8: 'Occult, inheritance intrigue, foreign or secret affairs, hidden '
        'transformation. Deep Rahu.',
    9: 'Unconventional dharma, foreign teachers, questioning tradition; '
        'father figure may be foreign or unusual.',
    10: 'Ambitious career, foreign profession, unconventional authority, '
        'viral public success; Rahu\'s favourite kendra.',
    11: 'Huge gains, ambitious network, materialist friends; Rahu\'s best '
        'house. Desire fulfillment.',
    12: 'Foreign settlement, addiction risk, hidden dealings, spiritual '
        'illusion; mystical or escapist Rahu.',
  },

  // --------------------------------------------------------------------- KETU
  PlanetType.ketu: {
    1: 'Detached personality, past-life ascetic, otherworldly presence; '
        'identity confusion or spiritual recognition.',
    2: 'Detachment from wealth, family distance, brief or cryptic speech; '
        'money comes and goes without grip.',
    3: 'Detached from siblings, silent courage, solo efforts; upachaya '
        'but quiet.',
    4: 'Emotional detachment, home instability, distant mother, restless '
        'soul; happiness sought elsewhere.',
    5: 'Detachment from children (delays or few), mystical creativity, '
        'past-life intellectual merits.',
    6: 'Excellent. Defeats enemies supernaturally, overcomes disease '
        'through detachment. Ketu\'s preferred seat.',
    7: 'Detachment from marriage, unconventional or absent partnership, '
        'spiritual or ascetic spouse.',
    8: 'Occult mastery, past-life longevity, moksha through transformation. '
        'Classical spiritual Ketu.',
    9: 'Spiritual dharma, detached from formal religion, inner guru rather '
        'than external tradition.',
    10: 'Detached career, spiritual or hidden profession, unconventional '
        'authority; fame without attachment.',
    11: 'Restrained gains, few but deep friends, moksha-oriented network; '
        'material desires attenuated.',
    12: 'Natural moksha placement, spiritual retreat, monastic tendencies, '
        'foreign liberation; Ketu\'s home ground.',
  },
};

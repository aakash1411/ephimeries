import '../../../domain/models/enums.dart';

/// Narrative for each Maha dasha lord in the Vimshottari system.
///
/// These are archetypal descriptions. The *actual* experience of a given
/// maha dasha depends on that planet's natal strength, house placement,
/// aspects, and the lord-of-dispositor chain. The text below sets the
/// baseline "flavour" of the period, to be modulated by chart specifics.
///
/// Durations:
/// Ketu 7y · Venus 20y · Sun 6y · Moon 10y · Mars 7y · Rahu 18y · Jupiter 16y
/// · Saturn 19y · Mercury 17y  (total: 120 years. One Parashari cycle)
const Map<PlanetType, String> kMahaDashaNarratives = {
  PlanetType.sun:
      'The 6-year Sun mahadasha foregrounds authority, visibility, and the '
      'relationship with the father or father-figures. Career prospects '
      'often accelerate, especially in government, leadership, or '
      'recognition-adjacent fields. Ego, pride, and health of the heart / '
      'spine come into focus. The Sun demands that the native step into '
      'who they really are. Conflicts with authority (or becoming one) are '
      'a recurring motif; Sun in a trikona or own/exalted sign can deliver '
      'raja-yoga results, while a debilitated or afflicted Sun brings '
      'ego-wounds and reputation tests.',
  PlanetType.moon:
      'The 10-year Moon mahadasha centres emotional life, mother, home, '
      'and the public image. Public-facing success, popularity, and '
      'significant domestic events (marriage, children, property) often '
      'cluster here. Mind, memory, and mental health track the Moon\'s '
      'natal strength: a well-placed Moon brings stability and rapport, '
      'while an afflicted Moon brings anxiety, fluctuation, and fluid-'
      'related health issues. Women and water-themes (travel, emotions, '
      'nurturing) are prominent.',
  PlanetType.mars:
      'The 7-year Mars mahadasha is an action period. Property disputes, '
      'sibling dynamics, athletic or military pursuits, surgery, and '
      'litigation all peak. Career moves often involve bold risk. Energy '
      'and courage rise; so does temperament and accident-proneness. Mars '
      'in a kendra/trikona with good strength delivers executive success '
      'and raja-yoga results; afflicted Mars brings blood, bone, and '
      'conflict issues. Younger siblings feature prominently.',
  PlanetType.mercury:
      'The 17-year Mercury mahadasha favours intellectual pursuits, '
      'communication, writing, trade, and relationships with peers and '
      'younger siblings. It is a long, chatty period. Much networking, '
      'travel, and short-cycle projects. Education and learning often '
      'advance dramatically. Business gains, legal matters, and skin/nerve '
      'health issues feature. Afflicted Mercury brings speech problems, '
      'anxiety, and financial scams.',
  PlanetType.jupiter:
      'The 16-year Jupiter mahadasha is classically the most auspicious. '
      'Wisdom, wealth, children, teachers, and dharma all come into '
      'alignment. Expansion is the theme: family (marriage, children), '
      'finances, spirituality, travel (especially foreign), and '
      'education/teaching roles. Jupiter\'s natal placement and dignity '
      'determine how liberal the grace: own/exalted delivers classical '
      'gajakesari-type results, while debilitated Jupiter brings '
      'misguidance or shallow dharma.',
  PlanetType.venus:
      'The 20-year Venus mahadasha. The longest period. Governs love, '
      'marriage, arts, luxury, vehicles, and refined pleasures. '
      'Relationships (romantic and business) peak, as do creative output, '
      'wealth, and comfort. Female energies and partners are prominent. '
      'Health of reproductive/urinary system, diabetes-related concerns, '
      'and eye issues can surface. Venus in its own or exalted sign brings '
      'classical malavya-yoga wealth and beauty; afflicted Venus brings '
      'scandals, attachment troubles, and overindulgence.',
  PlanetType.saturn:
      'The 19-year Saturn mahadasha is a long, formative, often difficult '
      'period. The period of karma ripening. Career builds slowly but '
      'permanently; discipline and duty dominate. Separations, delays, '
      'chronic health issues (joints, nervous system, chronic fatigue), '
      'and confrontation with aging or authority are classical. A '
      'well-placed Saturn (own sign, exalted, 3/6/10/11) delivers late-'
      'life eminence; afflicted Saturn brings poverty, isolation, and '
      'prolonged struggle. Regardless, Saturn teaches what nothing else '
      'can.',
  PlanetType.rahu:
      'The 18-year Rahu mahadasha amplifies desires and brings unusual, '
      'unexpected, often foreign elements into life. Ambition surges; '
      'unconventional careers, relationships, and geographies open up. '
      'Rahu is hungry. Fame, wealth, and power can all come, but often '
      'with shadows: scandals, confusion, and obsession. It\'s a period '
      'of rapid rise followed by humbling corrections if the native loses '
      'themselves to maya. Rahu in the 3rd, 6th, 10th, 11th tends to '
      'deliver; afflicted Rahu brings addiction, paranoia, and reversal.',
  PlanetType.ketu:
      'The 7-year Ketu mahadasha is a period of detachment, dissolution, '
      'and inward turning. Established structures (career, relationships, '
      'identity) may feel hollow or fall away, creating space for '
      'spiritual insight. Occult and mystical interests surge. Health '
      'issues tend to be mysterious or hard to diagnose. Ketu in the 9th, '
      '12th, or with Jupiter delivers classical moksha and wisdom; '
      'afflicted Ketu brings confusion, accidents, and sudden losses. The '
      'theme: let go of what isn\'t real.',
};

/// Antar dasha lords. Shorter modifiers inside the Maha dasha. The actual
/// theme of a period is the **combination** of maha + antar lords, their
/// mutual relationship (friend/enemy), and their joint placement in the
/// natal chart.
const Map<PlanetType, String> kAntarDashaModifiers = {
  PlanetType.sun:
      'A sub-period of ego assertion, paternal themes, authority dynamics, '
      'and visibility. Short career pushes or recognition moments; watch '
      'heart/spine health.',
  PlanetType.moon:
      'A sub-period emphasising mind, mother, home, and public '
      'relationships. Emotional volatility or public attention; fluids '
      'and women prominent.',
  PlanetType.mars:
      'A sub-period of bold action, conflict, property or sibling themes, '
      'and physical energy. Injuries, surgery, or decisive moves are '
      'classical.',
  PlanetType.mercury:
      'A sub-period of communication, learning, short journeys, and deals. '
      'Peers and younger siblings active; skin/nerves need attention.',
  PlanetType.jupiter:
      'A sub-period of expansion, wisdom, possibly marriage or children, '
      'and dharmic opportunity. Weight gain, liver issues on the shadow '
      'side.',
  PlanetType.venus:
      'A sub-period of relationships, arts, comforts, and sensual '
      'pleasures. Romance and luxury peak; overindulgence is the watchout.',
  PlanetType.saturn:
      'A sub-period of discipline, delay, duty, and confrontation with '
      'karma. Slow but structural gains; chronic health issues may surface.',
  PlanetType.rahu:
      'A sub-period of unexpected events, foreign influences, obsession, '
      'and ambition. Things come from unusual directions. Gains and '
      'scandals both.',
  PlanetType.ketu:
      'A sub-period of detachment, sudden loss, spiritual insight, or '
      'mysterious events. Energy withdraws; things end to make space.',
};

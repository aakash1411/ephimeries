import '../../../domain/models/enums.dart';

/// Authentic Parashari lagna (ascendant) descriptions.
///
/// Each entry summarises the sign's classical qualities (element, modality,
/// ruling graha) and the archetypal tone of a native born under that Lagna,
/// drawing from BPHS, Phaladeepika, and Saravali.
///
/// These are concise blurbs. 2–3 sentences. Intended as a starting point.
/// Specific yogas, planetary strengths, and dasha context refine the picture.
const Map<ZodiacSign, String> kLagnaDescriptions = {
  ZodiacSign.aries:
      'Mesha Lagna. Ruled by Mars. A fiery, cardinal (chara) sign giving a '
      'pioneering, action-first temperament. Classical texts describe a lean, '
      'wiry build, quick temper, and natural command. Sun exalts in the 1st '
      'house here, adding sustained vitality and leadership when well-placed.',
  ZodiacSign.taurus:
      'Vrishabha Lagna. Ruled by Venus. An earthy, fixed (sthira) sign '
      'producing patient, sensuous, wealth-accumulating natives. BPHS notes '
      'a strong neck and jaw, even temperament, and attachment to comfort. '
      'Moon exalts here in the 1st, conferring emotional steadiness and '
      'rapport with the public when strong.',
  ZodiacSign.gemini:
      'Mithuna Lagna. Ruled by Mercury. An airy, dual (dwisvabhava) sign '
      'marked by intellectual quickness, communication, and restlessness. '
      'Classical authors describe a tall, slim build and youthful features. '
      'Careers often involve speech, writing, or trade; two distinct phases '
      'of occupation are common.',
  ZodiacSign.cancer:
      'Karka Lagna. Ruled by the Moon. A watery, cardinal sign conferring '
      'emotional depth, maternal instinct, and sensitivity to environment. '
      'Jupiter exalts in the 1st, which Parashara calls a special boon for '
      'dharmic disposition and guru\'s grace. Moods and digestion both swing '
      'with the Moon.',
  ZodiacSign.leo:
      'Simha Lagna. Ruled by the Sun. Fiery, fixed, and inherently regal. '
      'Natives carry dignity, self-directed authority, and a strong sense of '
      'honour. Saravali describes the Leo-rising body as broad-shouldered '
      'with a leonine gait. The core vulnerability is pride; flattery and '
      'ego-wounds both land harder than most recognise.',
  ZodiacSign.virgo:
      'Kanya Lagna. Ruled by Mercury. Earthy, mutable, analytical. Mercury '
      'exalts in the 1st in Virgo, sharpening discernment, language, and '
      'service orientation. Natives tend toward health consciousness and '
      'detail-craft. The shadow side is over-criticism of self and others, '
      'and a tendency to worry about what Mercury already solved.',
  ZodiacSign.libra:
      'Tula Lagna. Ruled by Venus. Airy, cardinal, the sign of balance and '
      'exchange. Saturn exalts here in the 1st, granting patience, a judicial '
      'temperament, and long-view diplomacy. Natives are partnership-oriented '
      'and aesthetically refined. Decision-paralysis is the classical '
      'weakness. Weighing both sides becomes weighing forever.',
  ZodiacSign.scorpio:
      'Vrishchika Lagna. Ruled by Mars (with Ketu as co-lord in some '
      'schools). Watery, fixed, the sign of depth and transformation. '
      'Natives are investigative, secretive, and capable of total '
      'reinvention. BPHS links Scorpio rising to occult aptitude, medical '
      'and research fields, and intense emotional currents below a '
      'controlled surface.',
  ZodiacSign.sagittarius:
      'Dhanu Lagna. Ruled by Jupiter. Fiery, mutable, expansive. Natives '
      'are philosophical, truth-seeking, and drawn to teaching, law, or '
      'higher knowledge. Classical texts note a tall frame, cheerful face, '
      'and dharmic orientation. Foreign travel and long-distance connections '
      'are a recurring theme. Jupiter wants horizon.',
  ZodiacSign.capricorn:
      'Makara Lagna. Ruled by Saturn. Earthy, cardinal, the sign of '
      'structured ambition. Mars exalts in the 1st, giving executive '
      'endurance and a capacity for long campaigns. Parashari tradition '
      'describes slow but certain rise: nothing arrives early, most things '
      'arrive permanently. The natural temperament is reserved, practical, '
      'duty-bound.',
  ZodiacSign.aquarius:
      'Kumbha Lagna. Ruled by Saturn (traditional; Rahu as modern co-lord). '
      'Airy, fixed, humanitarian. Natives combine Saturn\'s conservatism '
      'with an eccentric, system-reforming bent. Group affiliations and '
      'unconventional professions dominate. Recognition tends to arrive '
      'later in life and from unexpected quarters.',
  ZodiacSign.pisces:
      'Meena Lagna. Ruled by Jupiter. Watery, mutable, devotional. Venus '
      'exalts in the 1st, which classical authors associate with artistic '
      'gift, spiritual receptivity, and compassion. Boundaries are porous: '
      'the native absorbs the room. Escapism and idealisation are the '
      'classical watchouts, but so is an under-appreciated capacity for '
      'selfless service.',
};

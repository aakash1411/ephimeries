import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';

/// Visual constants used by both North- and South-Indian chart painters.
///
/// Keeping them in one place makes the two painters match and lets tests
/// reference exact pixel colors / sizes.
class ChartPalette {
  const ChartPalette({
    required this.frame,
    required this.cell,
    required this.text,
    required this.muted,
    required this.ascendant,
    required this.highlight,
  });

  /// Outer frame / diagonal / grid stroke.
  final Color frame;

  /// Default cell fill.
  final Color cell;

  /// Primary text (planet / sign abbreviation).
  final Color text;

  /// Secondary text (house number label).
  final Color muted;

  /// Ascendant cell fill.
  final Color ascendant;

  /// Active / selected cell fill.
  final Color highlight;

  factory ChartPalette.fromTheme(ThemeData theme) {
    final cs = theme.colorScheme;
    return ChartPalette(
      frame: cs.onSurface.withValues(alpha: 0.7),
      cell: cs.surface,
      text: cs.onSurface,
      muted: cs.onSurface.withValues(alpha: 0.55),
      ascendant: cs.primary.withValues(alpha: 0.18),
      highlight: cs.primary.withValues(alpha: 0.32),
    );
  }
}

/// Planet colours per the Phase 5 design spec. Tuned for contrast against
/// both the dark (#0D0F1A) and light (#F5F3EE) backgrounds.
const Map<PlanetType, Color> kPlanetColors = <PlanetType, Color>{
  PlanetType.sun: Color(0xFFFF8C00), // amber
  PlanetType.moon: Color(0xFFCDD5D8), // silver
  PlanetType.mars: Color(0xFFE04040), // red
  PlanetType.mercury: Color(0xFF4CAF50), // green
  PlanetType.jupiter: Color(0xFFFFD700), // gold
  PlanetType.venus: Color(0xFFFF80AB), // pink
  PlanetType.saturn: Color(0xFF7986CB), // indigo
  PlanetType.rahu: Color(0xFF9575CD), // violet
  PlanetType.ketu: Color(0xFF90A4AE), // grey-blue
};

/// Short two-letter abbreviations used inside chart cells.
const Map<PlanetType, String> kPlanetAbbr = <PlanetType, String>{
  PlanetType.sun: 'Su',
  PlanetType.moon: 'Mo',
  PlanetType.mars: 'Ma',
  PlanetType.mercury: 'Me',
  PlanetType.jupiter: 'Ju',
  PlanetType.venus: 'Ve',
  PlanetType.saturn: 'Sa',
  PlanetType.rahu: 'Ra',
  PlanetType.ketu: 'Ke',
};

/// Three-letter zodiac sign abbreviations.
const Map<ZodiacSign, String> kSignAbbr = <ZodiacSign, String>{
  ZodiacSign.aries: 'Ar',
  ZodiacSign.taurus: 'Ta',
  ZodiacSign.gemini: 'Ge',
  ZodiacSign.cancer: 'Cn',
  ZodiacSign.leo: 'Le',
  ZodiacSign.virgo: 'Vi',
  ZodiacSign.libra: 'Li',
  ZodiacSign.scorpio: 'Sc',
  ZodiacSign.sagittarius: 'Sg',
  ZodiacSign.capricorn: 'Cp',
  ZodiacSign.aquarius: 'Aq',
  ZodiacSign.pisces: 'Pi',
};

/// Convention: natural malefics vs natural benefics (for subtle colouring).
bool isNaturalMalefic(PlanetType p) =>
    p == PlanetType.sun ||
    p == PlanetType.mars ||
    p == PlanetType.saturn ||
    p == PlanetType.rahu ||
    p == PlanetType.ketu;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/timezone_service.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'chart_display.dart';
import 'chart_theme.dart';

/// Renders the natal chart with transit planets summarised below and their
/// natal-house mapping shown in a compact table.
///
/// (Visually superimposing transit glyphs on the natal painter is Phase 4+;
/// the summary list is already semantically complete.)
class TransitOverlayWidget extends StatelessWidget {
  const TransitOverlayWidget({
    super.key,
    required this.natal,
    required this.transit,
  });

  final VedicChartData natal;
  final VedicChartData transit;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd().add_jm();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Natal · ${TimezoneService.formatInZone(natal.profile.dateTime, natal.profile.timezoneName, df)}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        ChartDisplayWidget(data: natal, title: 'Natal'),
        const SizedBox(height: 18),
        Text(
          'Transit · ${df.format(transit.profile.dateTime.toLocal())}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        _TransitSummary(natal: natal, transit: transit),
      ],
    );
  }
}

class _TransitSummary extends StatelessWidget {
  const _TransitSummary({required this.natal, required this.transit});
  final VedicChartData natal;
  final VedicChartData transit;

  int _natalHouseFor(ZodiacSign sign) {
    // Whole-sign mapping: house 1 starts at the ascendant sign.
    return ((sign.index - natal.ascendantSign.index + 12) % 12) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final PlanetPosition p in transit.planets)
          _TransitRow(planet: p, natalHouse: _natalHouseFor(p.sign)),
      ],
    );
  }
}

class _TransitRow extends StatelessWidget {
  const _TransitRow({required this.planet, required this.natalHouse});
  final PlanetPosition planet;
  final int natalHouse;

  @override
  Widget build(BuildContext context) {
    final color = kPlanetColors[planet.planet]!;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: color.withValues(alpha: 0.25),
        foregroundColor: color,
        child: Text(kPlanetAbbr[planet.planet]!),
      ),
      title: Text(
        '${planet.planet.sanskrit} — ${planet.sign.sanskrit} '
        '${planet.degree.toStringAsFixed(2)}°'
        '${planet.isRetrograde ? '  ℞' : ''}',
      ),
      subtitle: Text(
        'Transiting natal house $natalHouse  ·  ${planet.nakshatra.name} '
        'pada ${planet.nakshatraPada}',
      ),
    );
  }
}

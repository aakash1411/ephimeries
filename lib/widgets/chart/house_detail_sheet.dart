import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/formatters.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import '../../providers/settings_provider.dart';
import 'chart_theme.dart';

/// Bottom sheet that lists the planets placed in a house when the user taps
/// a chart cell.
Future<void> showHouseDetailSheet(
  BuildContext context, {
  required VedicChartData chart,
  required int house,
}) {
  final housed = chart.planets.where((p) => p.house == house).toList();
  final hd = chart.houseData.firstWhere((h) => h.house == house);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'House $house · ${hd.sign.sanskrit}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Cusp: ${hd.cuspDegree.toStringAsFixed(2)}°',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (housed.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No planets in this house')),
              )
            else
              for (final p in housed) _PlanetRow(p: p),
          ],
        ),
      );
    },
  );
}

class _PlanetRow extends ConsumerWidget {
  const _PlanetRow({required this.p});
  final PlanetPosition p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = kPlanetColors[p.planet]!;
    final lang = ref.watch(settingsProvider.select((s) => s.nameLanguage));
    final fmt = ref.watch(settingsProvider.select((s) => s.degreeFormat));
    final showRx = ref.watch(settingsProvider.select((s) => s.showRetrograde));
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.25),
        foregroundColor: color,
        child: Text(kPlanetAbbr[p.planet]!),
      ),
      title: Text(
        '${ChartFormatters.planet(p.planet, lang)}  ·  '
        '${ChartFormatters.sign(p.sign, lang)} '
        '${ChartFormatters.degree(p.degree, fmt)}'
        '${(showRx && p.isRetrograde) ? '  ℞' : ''}',
      ),
      subtitle:
          Text('${p.nakshatra.name} · pada ${p.nakshatraPada}'),
    );
  }
}

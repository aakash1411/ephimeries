import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/formatters.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/vedic_chart_data.dart';
import '../../providers/settings_provider.dart';

/// Single-line summary: Lagna · Moon · Sun · Moon-Nakshatra.
/// Names follow the active `AppSettings.nameLanguage`.
class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key, required this.chart});
  final VedicChartData chart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.nameLanguage));
    final moon = _findSign(PlanetType.moon);
    final sun = _findSign(PlanetType.sun);
    final muted = Theme.of(context).textTheme.labelSmall;
    final strong = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Lagna',
            value: ChartFormatters.sign(chart.ascendantSign, lang),
            muted: muted,
            strong: strong,
          ),
          _Chip(
            label: 'Moon',
            value: moon == null ? '—' : ChartFormatters.sign(moon, lang),
            muted: muted,
            strong: strong,
          ),
          _Chip(
            label: 'Sun',
            value: sun == null ? '—' : ChartFormatters.sign(sun, lang),
            muted: muted,
            strong: strong,
          ),
          _Chip(
            label: 'Nakshatra',
            value: chart.nakshatra.name,
            muted: muted,
            strong: strong,
          ),
        ],
      ),
    );
  }

  ZodiacSign? _findSign(PlanetType p) {
    for (final pp in chart.planets) {
      if (pp.planet == p) return pp.sign;
    }
    return null;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.muted,
    required this.strong,
  });
  final String label;
  final String value;
  final TextStyle? muted;
  final TextStyle? strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label:', style: muted),
            const SizedBox(width: 4),
            Text(value, style: strong),
          ],
        ),
      ),
    );
  }
}

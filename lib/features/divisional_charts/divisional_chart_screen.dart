import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chart_providers.dart';
import '../../widgets/chart/chart_display.dart';
import '../../widgets/chart/divisional_chart_selector.dart';
import '../../widgets/chart/planet_table.dart';
import '../../widgets/common/approximate_banner.dart';
import '../../widgets/common/chart_skeleton.dart';

class DivisionalChartScreen extends ConsumerStatefulWidget {
  const DivisionalChartScreen({super.key});

  @override
  ConsumerState<DivisionalChartScreen> createState() =>
      _DivisionalChartScreenState();
}

class _DivisionalChartScreenState extends ConsumerState<DivisionalChartScreen> {
  int _selected = 9;

  @override
  Widget build(BuildContext context) {
    final chart = ref.watch(divisionalChartProvider(_selected));
    final varga =
        kVargaCharts.firstWhere((v) => v.divisor == _selected);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DivisionalChartSelector(
          selected: _selected,
          onSelect: (d) => setState(() => _selected = d),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: chart.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: ChartSkeleton()),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (c) {
              if (c == null) {
                return const Center(child: Text('No profile selected'));
              }
              final title = 'D${varga.divisor} · ${varga.name}';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    varga.signifies,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (c.profile.birthTimeUnknown)
                    const ApproximateBirthTimeBanner(),
                  const SizedBox(height: 8),
                  ChartDisplayWidget(data: c, title: title),
                  const SizedBox(height: 16),
                  PlanetDetailTable(chart: c),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

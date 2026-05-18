import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/services/chart_share_service.dart';
import '../../data/services/timezone_service.dart';
import '../../domain/models/vedic_chart_data.dart';
import '../../providers/chart_providers.dart';
import '../../widgets/chart/chart_display.dart';
import '../../widgets/chart/planet_table.dart';
import '../../widgets/chart/quick_stats_row.dart';
import '../../widgets/common/approximate_banner.dart';
import '../../widgets/common/chart_skeleton.dart';

class NatalChartScreen extends ConsumerStatefulWidget {
  const NatalChartScreen({super.key});

  @override
  ConsumerState<NatalChartScreen> createState() => _NatalChartScreenState();
}

class _NatalChartScreenState extends ConsumerState<NatalChartScreen> {
  final _shareKey = GlobalKey();
  final _share = const ChartShareService();
  bool _sharing = false;

  Future<void> _shareChart(VedicChartData chart) async {
    setState(() => _sharing = true);
    try {
      final df = DateFormat('dd/MM/yyyy').add_jm();
      await _share.shareChart(
        boundaryKey: _shareKey,
        fileName: 'ephimeries-${chart.profile.name}-D1',
        text: 'Natal chart for ${chart.profile.name}. '
            '${TimezoneService.formatInZone(chart.profile.dateTime, chart.profile.timezoneName, df)} · '
            '${chart.profile.placeLabel}',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vedicChartProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: ChartSkeleton()),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (chart) {
        if (chart == null) {
          return const Center(child: Text('No profile selected'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'D1 · Lagna / Rasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _sharing ? null : () => _shareChart(chart),
                  icon: _sharing
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share),
                  label: const Text('Share'),
                ),
              ],
            ),
            if (chart.profile.birthTimeUnknown)
              const ApproximateBirthTimeBanner(),
            const SizedBox(height: 6),
            QuickStatsRow(chart: chart),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: _shareKey,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(12),
                child: ChartDisplayWidget(data: chart, title: 'D1 · Rasi'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Planetary positions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            PlanetDetailTable(chart: chart),
          ],
        );
      },
    );
  }
}

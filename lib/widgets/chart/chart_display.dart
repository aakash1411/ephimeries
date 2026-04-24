import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/vedic_chart_data.dart';
import '../../providers/settings_provider.dart';
import 'north_indian_chart.dart';
import 'south_indian_chart.dart';

/// Renders either a North-Indian or South-Indian chart depending on
/// `settingsProvider.chartStyle`. Switch is instant — both painters consume
/// the same [VedicChartData].
class ChartDisplayWidget extends ConsumerWidget {
  const ChartDisplayWidget({super.key, required this.data, this.title});

  final VedicChartData data;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(settingsProvider.select((s) => s.chartStyle));
    final showRx = ref.watch(settingsProvider.select((s) => s.showRetrograde));
    return switch (style) {
      ChartStyle.northIndian => NorthIndianChart(
          data: data,
          title: title,
          showRetrograde: showRx,
        ),
      ChartStyle.southIndian => SouthIndianChart(
          data: data,
          title: title,
          showRetrograde: showRx,
        ),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/vedic_chart_data.dart';
import '../../providers/chart_providers.dart';
import '../../widgets/chart/chart_display.dart';
import '../../widgets/chart/planet_table.dart';
import '../../widgets/chart/transit_overlay.dart';
import '../../widgets/common/approximate_banner.dart';
import '../../widgets/common/chart_skeleton.dart';

enum _TransitView { both, natal, transit }

class TransitScreen extends ConsumerStatefulWidget {
  const TransitScreen({super.key});

  @override
  ConsumerState<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends ConsumerState<TransitScreen> {
  _TransitView _view = _TransitView.both;

  Future<void> _pickMoment() async {
    final moment = ref.read(transitMomentProvider);
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: moment.toLocal(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(moment.toLocal()),
    );
    if (time == null) return;
    ref.read(transitMomentProvider.notifier).state = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  @override
  Widget build(BuildContext context) {
    final moment = ref.watch(transitMomentProvider);
    final df = DateFormat('dd/MM/yyyy').add_jm();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transit: ${df.format(moment.toLocal())}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Device local time',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(transitMomentProvider.notifier).state =
                          DateTime.now().toUtc();
                    },
                    icon: const Icon(Icons.today),
                    label: const Text('Today'),
                  ),
                  IconButton(
                    tooltip: 'Pick date',
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickMoment,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SegmentedButton<_TransitView>(
                segments: const [
                  ButtonSegment(
                    value: _TransitView.both,
                    label: Text('Both'),
                    icon: Icon(Icons.layers_outlined),
                  ),
                  ButtonSegment(
                    value: _TransitView.natal,
                    label: Text('Natal'),
                  ),
                  ButtonSegment(
                    value: _TransitView.transit,
                    label: Text('Transit'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() => _view = s.first),
              ),
            ],
          ),
        ),
        const _Legend(),
        Expanded(child: _TransitBody(view: _view)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _LegendDot(color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          const Text('Natal  '),
          const SizedBox(width: 12),
          _LegendDot(color: Colors.orange.shade600),
          const SizedBox(width: 4),
          const Text('Transit'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TransitBody extends ConsumerWidget {
  const _TransitBody({required this.view});
  final _TransitView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final natalAsync = ref.watch(vedicChartProvider);
    final transitAsync = ref.watch(transitChartProvider);
    if (natalAsync.isLoading || transitAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: ChartSkeleton()),
      );
    }
    if (natalAsync.hasError) {
      return Center(child: Text('Error: ${natalAsync.error}'));
    }
    if (transitAsync.hasError) {
      return Center(child: Text('Error: ${transitAsync.error}'));
    }
    final natal = natalAsync.valueOrNull;
    final transit = transitAsync.valueOrNull;
    if (natal == null || transit == null) {
      return const Center(child: Text('No profile selected'));
    }
    final body = switch (view) {
      _TransitView.natal => _SingleChartView(chart: natal, title: 'Natal'),
      _TransitView.transit =>
        _SingleChartView(chart: transit, title: 'Transit'),
      _TransitView.both => TransitOverlayWidget(natal: natal, transit: transit),
    };
    if (!natal.profile.birthTimeUnknown) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: ApproximateBirthTimeBanner(),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _SingleChartView extends StatelessWidget {
  const _SingleChartView({required this.chart, required this.title});
  final VedicChartData chart;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ChartDisplayWidget(data: chart, title: title),
        const SizedBox(height: 12),
        PlanetDetailTable(chart: chart),
      ],
    );
  }
}

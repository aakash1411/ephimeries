import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/birth_profile.dart';
import '../../domain/models/dashboard_panel_type.dart';
import '../../providers/birth_profiles_provider.dart';
import '../../providers/chart_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/chart/chart_display.dart';
import '../../widgets/chart/dasha_timeline.dart';
import '../../widgets/chart/planet_table.dart';
import '../../widgets/chart/transit_overlay.dart';
import '../../widgets/common/chart_skeleton.dart';
import 'panel_type_picker.dart';

/// A single panel in the iPad multi-chart dashboard.
///
/// Renders a header bar (title + gear icon) and the chart/widget body.
/// Double-tap expands the panel to full-screen via a dialog overlay.
class DashboardPanel extends ConsumerWidget {
  const DashboardPanel({
    super.key,
    required this.index,
  });

  /// Zero-based slot index into the dashboard layout list.
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(dashboardLayoutProvider);
    if (index >= layout.length) return const SizedBox.shrink();
    final panelType = layout[index];
    return Card(
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _PanelHeader(
            panelType: panelType,
            onChangeType: () => _pickType(context, ref, panelType),
          ),
          Expanded(
            child: GestureDetector(
              onDoubleTap: () => _expandPanel(context, panelType, ref),
              child: _PanelBody(panelType: panelType),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickType(
    BuildContext context,
    WidgetRef ref,
    DashboardPanelType current,
  ) async {
    final chosen = await PanelTypePicker.show(context, current: current);
    if (chosen != null && chosen != current) {
      ref.read(dashboardLayoutProvider.notifier).setPanel(index, chosen);
    }
  }

  void _expandPanel(
    BuildContext context,
    DashboardPanelType panelType,
    WidgetRef ref,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ExpandedPanelScreen(panelType: panelType),
      ),
    );
  }
}

/// Compact header showing the panel type label and a settings gear.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.panelType,
    required this.onChangeType,
  });

  final DashboardPanelType panelType;
  final VoidCallback onChangeType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              panelType.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 16,
              icon: const Icon(Icons.tune),
              tooltip: 'Change panel type',
              onPressed: onChangeType,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the correct chart/widget based on the [panelType].
///
/// Uses the family providers directly with the active profile, so each panel
/// shares the same cached data.
class _PanelBody extends ConsumerWidget {
  const _PanelBody({required this.panelType});

  final DashboardPanelType panelType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) {
      return const Center(child: Text('No profile selected'));
    }

    // Dasha timeline
    if (panelType == DashboardPanelType.dasha) {
      return _DashaPanel(profile: profile);
    }

    // Planet positions table
    if (panelType == DashboardPanelType.planetTable) {
      return _PlanetTablePanel(profile: profile);
    }

    // Transit overlay
    if (panelType == DashboardPanelType.transitOverlay) {
      return _TransitOverlayPanel(profile: profile);
    }

    // Transit chart (standalone)
    if (panelType == DashboardPanelType.transit) {
      return _TransitChartPanel(profile: profile);
    }

    // Divisional chart (D1 through D60)
    final divisor = panelType.divisor;
    if (divisor != null) {
      return _DivisionalPanel(profile: profile, divisor: divisor);
    }

    return const Center(child: Text('Unknown panel type'));
  }
}

class _DivisionalPanel extends ConsumerWidget {
  const _DivisionalPanel({required this.profile, required this.divisor});
  final BirthProfile profile;
  final int divisor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = DivisionalChartArgs(profile: profile, divisor: divisor);
    final async = ref.watch(divisionalChartFamilyProvider(args));

    return async.when(
      loading: () => const Center(child: ChartSkeleton()),
      error: (e, _) => Center(child: Text('Error: $e', maxLines: 3)),
      data: (chart) => Padding(
        padding: const EdgeInsets.all(6),
        child: ChartDisplayWidget(data: chart),
      ),
    );
  }
}

class _DashaPanel extends ConsumerWidget {
  const _DashaPanel({required this.profile});
  final BirthProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashaChartProvider(profile));

    return async.when(
      loading: () => const Center(child: ChartSkeleton()),
      error: (e, _) => Center(child: Text('Error: $e', maxLines: 3)),
      data: (dasha) => DashaTimelineWidget(
        dasha: dasha,
        birthDate: profile.dateTime,
        timezoneName: profile.timezoneName,
      ),
    );
  }
}

class _PlanetTablePanel extends ConsumerWidget {
  const _PlanetTablePanel({required this.profile});
  final BirthProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(natalChartProvider(profile));

    return async.when(
      loading: () => const Center(child: ChartSkeleton()),
      error: (e, _) => Center(child: Text('Error: $e', maxLines: 3)),
      data: (chart) => SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: PlanetDetailTable(chart: chart),
      ),
    );
  }
}

class _TransitChartPanel extends ConsumerWidget {
  const _TransitChartPanel({required this.profile});
  final BirthProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moment = ref.watch(transitMomentProvider);
    final args = TransitChartArgs(profile: profile, date: moment);
    final async = ref.watch(transitChartFamilyProvider(args));

    return async.when(
      loading: () => const Center(child: ChartSkeleton()),
      error: (e, _) => Center(child: Text('Error: $e', maxLines: 3)),
      data: (chart) => Padding(
        padding: const EdgeInsets.all(6),
        child: ChartDisplayWidget(data: chart, title: 'Transit'),
      ),
    );
  }
}

class _TransitOverlayPanel extends ConsumerWidget {
  const _TransitOverlayPanel({required this.profile});
  final BirthProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final natalAsync = ref.watch(natalChartProvider(profile));
    final moment = ref.watch(transitMomentProvider);
    final transitAsync = ref.watch(
      transitChartFamilyProvider(
        TransitChartArgs(profile: profile, date: moment),
      ),
    );

    if (natalAsync.isLoading || transitAsync.isLoading) {
      return const Center(child: ChartSkeleton());
    }
    final natal = natalAsync.valueOrNull;
    final transit = transitAsync.valueOrNull;
    if (natal == null || transit == null) {
      return const Center(child: Text('Loading…'));
    }
    return TransitOverlayWidget(natal: natal, transit: transit);
  }
}

/// Full-screen view when a panel is double-tapped.
class _ExpandedPanelScreen extends StatelessWidget {
  const _ExpandedPanelScreen({required this.panelType});
  final DashboardPanelType panelType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(panelType.label),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _PanelBody(panelType: panelType),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/services/apple_intelligence_service.dart';
import '../../data/services/timezone_service.dart';
import '../../domain/models/birth_profile.dart';
import '../../domain/models/enums.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../providers/chart_providers.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/common/chart_skeleton.dart';
import 'analysis_engine.dart';
import 'planetary_dignity.dart';

/// Singleton-scoped Apple Intelligence service. Lives for the app's lifetime
/// since session creation is lightweight per-call.
final appleIntelligenceServiceProvider = Provider<AppleIntelligenceService>(
  (_) => AppleIntelligenceService(),
);

/// One-shot availability check — cached for the life of the process.
final aiAvailabilityProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appleIntelligenceServiceProvider).isAvailable();
});

/// Analysis tab: rule-based Parashari reading + (on iOS 26+) Apple
/// Intelligence streamed narrative. The content is derived from the
/// pure-function [AnalysisEngine]; this screen is display-only.
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pro Analysis is a one-time IAP. Until the user has purchased or
    // redeemed a tester code we render the paywall in place of the
    // report. The IAP service writes the entitlement back to settings,
    // so this build re-runs and unlocks the report immediately on
    // success.
    final entitled =
        ref.watch(purchaseProvider.select((s) => s.entitled));
    if (!entitled) {
      return const PaywallScreen(embedded: true);
    }

    final natalAsync = ref.watch(vedicChartProvider);
    final dashaAsync = ref.watch(dashaProvider);
    final transitAsync = ref.watch(transitChartProvider);

    return natalAsync.when(
      loading: () => const ChartSkeleton(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (natal) {
        if (natal == null) {
          return const _NoProfileState();
        }
        final report = AnalysisEngine.compute(
          natal: natal,
          dasha: dashaAsync.valueOrNull,
          transit: transitAsync.valueOrNull,
        );
        return _ReportView(report: report, profile: natal.profile);
      },
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report, required this.profile});
  final AnalysisReport report;
  final BirthProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _LagnaSection(
          lagna: report.lagnaSign,
          blurb: report.lagnaBlurb,
        ),
        const SizedBox(height: 12),
        _KeyPlacementsSection(placements: report.keyPlacements),
        const SizedBox(height: 12),
        if (report.dashaNote != null)
          _DashaSection(
            note: report.dashaNote!,
            timezoneName: profile.timezoneName,
          ),
        const SizedBox(height: 12),
        if (report.transitHighlights.isNotEmpty)
          _TransitSection(notes: report.transitHighlights),
        const SizedBox(height: 12),
        _AiReadingSection(profile: profile, report: report),
      ],
    );
  }
}

// ------------------------------------------------------------------- AI READING
class _AiReadingSection extends ConsumerStatefulWidget {
  const _AiReadingSection({required this.profile, required this.report});
  final BirthProfile profile;
  final AnalysisReport report;

  @override
  ConsumerState<_AiReadingSection> createState() => _AiReadingSectionState();
}

class _AiReadingSectionState extends ConsumerState<_AiReadingSection> {
  String _text = '';
  bool _running = false;
  Object? _error;

  Future<void> _start() async {
    setState(() {
      _running = true;
      _text = '';
      _error = null;
    });
    try {
      final svc = ref.read(appleIntelligenceServiceProvider);
      await svc.streamReading(
        profile: widget.profile,
        report: widget.report,
        onDelta: (_, cumulative) {
          if (!mounted) return;
          setState(() => _text = cumulative);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availability = ref.watch(aiAvailabilityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('AI reading', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  'Apple Intelligence',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            availability.when(
              loading: () => const _AvailabilityProbe(),
              error: (_, _) => _UnavailableNote(
                message: 'Could not check Apple Intelligence availability.',
              ),
              data: (avail) {
                if (!avail) {
                  return const _UnavailableNote(
                    message:
                        'Apple Intelligence isn\'t available on this device. '
                        'The rule-based analysis above still stands on its own.',
                  );
                }
                return _AiReadingBody(
                  running: _running,
                  text: _text,
                  error: _error,
                  onStart: _running ? null : _start,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityProbe extends StatelessWidget {
  const _AvailabilityProbe();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Expanded(child: Text('Checking Apple Intelligence…')),
      ],
    );
  }
}

class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _AiReadingBody extends StatelessWidget {
  const _AiReadingBody({
    required this.running,
    required this.text,
    required this.error,
    required this.onStart,
  });

  final bool running;
  final String text;
  final Object? error;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (text.isEmpty && error == null && !running)
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate on-device reading'),
            onPressed: onStart,
          ),
        if (running && text.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Generating…')),
              ],
            ),
          ),
        if (text.isNotEmpty) ...[
          Text(text, style: theme.textTheme.bodyMedium),
          if (running)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
                onPressed: onStart,
              ),
            ),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'AI error: $error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------- LAGNA
class _LagnaSection extends StatelessWidget {
  const _LagnaSection({required this.lagna, required this.blurb});
  final ZodiacSign lagna;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_5_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Chart signature',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_signLabel(lagna)} Ascendant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(blurb, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- KEY PLACEMENTS
class _KeyPlacementsSection extends StatelessWidget {
  const _KeyPlacementsSection({required this.placements});
  final List<PlacementNote> placements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (placements.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Key placements',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            for (final p in placements) ...[
              _PlacementTile(note: p),
              if (p != placements.last) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlacementTile extends StatelessWidget {
  const _PlacementTile({required this.note});
  final PlacementNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dignityColor = _dignityColor(note.dignity, theme.colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              _planetLabel(note.planet),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'in ${_signLabel(note.sign)} · H${note.house}',
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: dignityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dignityColor, width: 1),
              ),
              child: Text(
                note.dignity.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: dignityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (note.signBlurb.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(note.signBlurb, style: theme.textTheme.bodySmall),
        ],
        if (note.houseBlurb.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(note.houseBlurb,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ],
      ],
    );
  }
}

Color _dignityColor(Dignity d, ColorScheme scheme) => switch (d) {
      Dignity.exalted => Colors.green.shade600,
      Dignity.mooltrikona => Colors.green.shade400,
      Dignity.ownSign => Colors.teal.shade400,
      Dignity.friendSign => scheme.primary,
      Dignity.neutralSign => scheme.outline,
      Dignity.enemySign => Colors.orange.shade700,
      Dignity.debilitated => Colors.red.shade600,
    };

// --------------------------------------------------------------------- DASHA
class _DashaSection extends StatelessWidget {
  const _DashaSection({required this.note, required this.timezoneName});
  final DashaNote note;
  final String timezoneName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat.yMMMd();
    String fmt(DateTime utc) =>
        TimezoneService.formatInZone(utc, timezoneName, df);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Current dasha', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            _DashaCard(
              heading: 'Maha · ${_planetLabel(note.mahaLord)}',
              blurb: note.mahaBlurb,
              subtitle: 'Until ${fmt(note.mahaEnd)}',
            ),
            const SizedBox(height: 8),
            _DashaCard(
              heading: 'Antar · ${_planetLabel(note.antarLord)}',
              blurb: note.antarBlurb,
              subtitle: 'Until ${fmt(note.antarEnd)}',
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashaCard extends StatelessWidget {
  const _DashaCard({
    required this.heading,
    required this.blurb,
    required this.subtitle,
    this.secondary = false,
  });

  final String heading;
  final String blurb;
  final String subtitle;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = secondary
        ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.4)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 4),
          Text(subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 6),
          Text(blurb, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- TRANSITS
class _TransitSection extends StatelessWidget {
  const _TransitSection({required this.notes});
  final List<TransitNote> notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Transit highlights',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            for (final n in notes) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 10),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_planetLabel(n.transitPlanet)} in H${n.natalHouse}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(n.note,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              if (n != notes.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- NO PROFILE
class _NoProfileState extends StatelessWidget {
  const _NoProfileState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights, size: 64),
            SizedBox(height: 16),
            Text('Select a profile to analyse.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ FORMATTERS
String _signLabel(ZodiacSign s) => switch (s) {
      ZodiacSign.aries => 'Aries',
      ZodiacSign.taurus => 'Taurus',
      ZodiacSign.gemini => 'Gemini',
      ZodiacSign.cancer => 'Cancer',
      ZodiacSign.leo => 'Leo',
      ZodiacSign.virgo => 'Virgo',
      ZodiacSign.libra => 'Libra',
      ZodiacSign.scorpio => 'Scorpio',
      ZodiacSign.sagittarius => 'Sagittarius',
      ZodiacSign.capricorn => 'Capricorn',
      ZodiacSign.aquarius => 'Aquarius',
      ZodiacSign.pisces => 'Pisces',
    };

String _planetLabel(PlanetType p) => switch (p) {
      PlanetType.sun => 'Sun',
      PlanetType.moon => 'Moon',
      PlanetType.mars => 'Mars',
      PlanetType.mercury => 'Mercury',
      PlanetType.jupiter => 'Jupiter',
      PlanetType.venus => 'Venus',
      PlanetType.saturn => 'Saturn',
      PlanetType.rahu => 'Rahu',
      PlanetType.ketu => 'Ketu',
    };

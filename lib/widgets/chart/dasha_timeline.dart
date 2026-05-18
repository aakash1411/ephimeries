import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/timezone_service.dart';
import '../../domain/models/dasha_data.dart';
import '../../domain/models/enums.dart';
import 'chart_theme.dart';

/// Vertical accordion timeline of Vimshottari dasha periods.
///
/// - Current-period banner at the top with `NOW` badge
/// - Maha → Antar → Pratyantar, tap to expand
/// - Currently active period has a red-accented left border and `NOW` badge
/// - Each row is tinted with the classical planet colour
/// - Each Maha period displays the native's age at its start
class DashaTimelineWidget extends StatelessWidget {
  const DashaTimelineWidget({
    super.key,
    required this.dasha,
    required this.birthDate,
    required this.timezoneName,
    DateTime? now,
  }) : _now = now;

  final DashaData dasha;
  final DateTime birthDate;
  final String timezoneName;
  final DateTime? _now;

  DateTime get now => _now ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _CurrentBanner(dasha: dasha, now: now, timezoneName: timezoneName),
        const SizedBox(height: 12),
        Text(
          'Maha dasha sequence',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        for (final maha in dasha.mahaSequence)
          _DashaTile(
            period: maha,
            now: now,
            birthDate: birthDate,
            timezoneName: timezoneName,
          ),
      ],
    );
  }
}

class _CurrentBanner extends StatelessWidget {
  const _CurrentBanner({
    required this.dasha,
    required this.now,
    required this.timezoneName,
  });
  final DashaData dasha;
  final DateTime now;
  final String timezoneName;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    String fmt(DateTime utc) =>
        TimezoneService.formatInZone(utc, timezoneName, df);
    // Compute the active Maha/Antar at the true current instant, not the
    // stale snapshot captured when the dasha was originally fetched (RCA-5).
    final active = dasha.activeAt(now);
    final activeMaha = active.maha;
    final activeAntar = active.antar;
    final remainingDays = activeMaha.endDate.difference(now).inDays;
    final remainingYears = (remainingDays / 365.25).clamp(0, 120);
    final antarRemaining = activeAntar.endDate.difference(now).inDays;
    final color = kPlanetColors[activeMaha.planet]!;
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PlanetChip(planet: activeMaha.planet),
                const SizedBox(width: 10),
                Text(
                  'Current Dasha',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                const _NowBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activeMaha.planet.sanskrit,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              '${fmt(activeMaha.startDate)} → '
              '${fmt(activeMaha.endDate)} '
              '(~${remainingYears.toStringAsFixed(1)}y left)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 20),
            Row(
              children: [
                _PlanetChip(planet: activeAntar.planet),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Antar: ${activeAntar.planet.sanskrit}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Text(
              'Ends ${fmt(activeAntar.endDate)} '
              '(~${antarRemaining > 0 ? antarRemaining : 0}d left)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NowBadge extends StatelessWidget {
  const _NowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NOW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DashaTile extends StatelessWidget {
  const _DashaTile({
    required this.period,
    required this.now,
    required this.birthDate,
    required this.timezoneName,
  });
  final DashaPeriod period;
  final DateTime now;
  final DateTime birthDate;
  final String timezoneName;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    String fmt(DateTime utc) =>
        TimezoneService.formatInZone(utc, timezoneName, df);
    final color = kPlanetColors[period.planet]!;
    final active = period.contains(now);
    final indent = (period.level - 1) * 12.0;
    final ageAtStart = _yearsBetween(birthDate, period.startDate);

    final title = Row(
      children: [
        Expanded(
          child: Text(
            '${period.planet.sanskrit}  ·  '
            '${fmt(period.startDate)} → ${fmt(period.endDate)}',
            style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        if (period.level == 1)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'Age $ageAtStart',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        if (active)
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: _NowBadge(),
          ),
      ],
    );

    if (period.subPeriods.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: _LeafRow(color: color, active: active, child: title),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: active,
          dense: true,
          leading: _PlanetChip(planet: period.planet),
          title: title,
          childrenPadding: const EdgeInsets.only(left: 6),
          children: [
            for (final sub in period.subPeriods)
              _DashaTile(
                period: sub,
                now: now,
                birthDate: birthDate,
                timezoneName: timezoneName,
              ),
          ],
        ),
      ),
    );
  }

  int _yearsBetween(DateTime birth, DateTime at) {
    var years = at.year - birth.year;
    if (at.month < birth.month ||
        (at.month == birth.month && at.day < birth.day)) {
      years -= 1;
    }
    return years < 0 ? 0 : years;
  }
}

class _LeafRow extends StatelessWidget {
  const _LeafRow({required this.color, required this.active, required this.child});
  final Color color;
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.22 : 0.08),
        border: active
            ? Border(left: BorderSide(color: Colors.red.shade400, width: 3))
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

class _PlanetChip extends StatelessWidget {
  const _PlanetChip({required this.planet});
  final PlanetType planet;

  @override
  Widget build(BuildContext context) {
    final color = kPlanetColors[planet]!;
    return CircleAvatar(
      radius: 12,
      backgroundColor: color.withValues(alpha: 0.3),
      foregroundColor: color,
      child: Text(
        kPlanetAbbr[planet]!,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

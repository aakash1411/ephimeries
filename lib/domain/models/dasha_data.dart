import 'enums.dart';

/// A Vimshottari dasha period at any level (Maha / Antar / Pratyantar / Sookshma).
class DashaPeriod {
  const DashaPeriod({
    required this.planet,
    required this.startDate,
    required this.endDate,
    required this.level,
    this.subPeriods = const <DashaPeriod>[],
  });

  final PlanetType planet;
  final DateTime startDate;
  final DateTime endDate;

  /// 1 = Maha, 2 = Antar, 3 = Pratyantar, 4 = Sookshma.
  final int level;

  final List<DashaPeriod> subPeriods;

  bool contains(DateTime at) =>
      !at.isBefore(startDate) && at.isBefore(endDate);
}

/// Snapshot of where a profile currently is in the Vimshottari cycle.
class DashaData {
  const DashaData({
    required this.mahaDasha,
    required this.antarDasha,
    required this.current,
    required this.mahaSequence,
  });

  /// Currently active Maha dasha **at the moment this [DashaData] was
  /// computed**. Prefer [activeAt] when rendering so the banner reflects the
  /// true current instant, not the stale fetch-time instant.
  final DashaPeriod mahaDasha;

  /// Currently active Antar dasha (level 2) inside `mahaDasha` at compute-time.
  final DashaPeriod antarDasha;

  /// Deepest currently-active period available (Pratyantar/Sookshma if
  /// computed, else Antar) at compute-time.
  final DashaPeriod current;

  /// Full chronological list of Maha dashas (120-year cycle window).
  final List<DashaPeriod> mahaSequence;

  /// Active Maha / Antar / Pratyantar at [at]. Computed by descending the
  /// period tree — constant-time in the number of levels (≤3). If [at] falls
  /// inside a maha but outside its computed sub-periods, returns the first
  /// sub-period of that maha (more coherent than falling back to the stale
  /// snapshot's antar from a different maha).
  ({DashaPeriod maha, DashaPeriod antar, DashaPeriod pratyantar}) activeAt(
    DateTime at,
  ) {
    final maha = _pickActive(mahaSequence, at) ?? mahaDasha;
    final antar = _pickActive(maha.subPeriods, at) ??
        (maha.subPeriods.isNotEmpty ? maha.subPeriods.first : antarDasha);
    final pratyantar = _pickActive(antar.subPeriods, at) ??
        (antar.subPeriods.isNotEmpty ? antar.subPeriods.first : current);
    return (maha: maha, antar: antar, pratyantar: pratyantar);
  }

  static DashaPeriod? _pickActive(
    List<DashaPeriod> periods,
    DateTime at,
  ) {
    for (final p in periods) {
      if (p.contains(at)) return p;
    }
    return null;
  }
}

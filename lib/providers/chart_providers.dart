import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jyotish/jyotish.dart' as jy;

import '../data/repositories/chart_repository.dart';
import '../data/repositories/jyotish_chart_repository.dart';
import '../domain/models/birth_profile.dart';
import '../domain/models/dasha_data.dart';
import '../domain/models/panchang_data.dart';
import '../domain/models/vedic_chart_data.dart';
import 'birth_profiles_provider.dart';
import 'settings_provider.dart';

/// Singleton Swiss Ephemeris engine. Populated once at bootstrap via
/// `ProviderScope(overrides: [jyotishProvider.overrideWithValue(engine)])`.
///
/// Throws if accessed before [initializeJyotish] completes.
final jyotishProvider = Provider<jy.Jyotish>((ref) {
  throw UnimplementedError(
    'jyotishProvider must be overridden at app bootstrap after '
    'initializeJyotish() completes.',
  );
});

/// One-shot Swiss Ephemeris initializer used at startup. Safe to call
/// multiple times — `jyotish.initialize()` is idempotent.
Future<jy.Jyotish> initializeJyotish() async {
  final engine = jy.Jyotish();
  await engine.initialize();
  return engine;
}

/// Production [ChartRepository] bound to the active ayanamsa.
final chartRepositoryProvider = Provider<ChartRepository>((ref) {
  final engine = ref.watch(jyotishProvider);
  final ayanamsa = ref.watch(settingsProvider.select((s) => s.ayanamsa));
  return JyotishChartRepository(engine: engine, ayanamsa: ayanamsa);
});

// ---------------------------------------------------------------------------
// Profile-scoped chart providers
// ---------------------------------------------------------------------------

/// Natal (D1) chart for a specific profile.
///
/// Family-keyed by [BirthProfile]; kept alive by the profile being watched
/// elsewhere so repeated reads during navigation don't recompute.
final natalChartProvider = FutureProvider.autoDispose
    .family<VedicChartData, BirthProfile>((ref, profile) {
  ref.keepAlive(); // birth data never changes → cache forever
  return ref.watch(chartRepositoryProvider).getNatalChart(profile);
});

/// Dasha for a specific profile (birth data never changes → cache forever).
final dashaChartProvider =
    FutureProvider.autoDispose.family<DashaData, BirthProfile>((ref, profile) {
  ref.keepAlive();
  return ref.watch(chartRepositoryProvider).getDasha(profile);
});

/// Divisional chart parameters.
class DivisionalChartArgs {
  const DivisionalChartArgs({required this.profile, required this.divisor});

  final BirthProfile profile;
  final int divisor;

  @override
  bool operator ==(Object other) =>
      other is DivisionalChartArgs &&
      other.profile.id == profile.id &&
      other.divisor == divisor;

  @override
  int get hashCode => Object.hash(profile.id, divisor);
}

final divisionalChartFamilyProvider = FutureProvider.autoDispose
    .family<VedicChartData, DivisionalChartArgs>((ref, args) {
  ref.keepAlive(); // Varga charts depend only on birth data
  return ref
      .watch(chartRepositoryProvider)
      .getDivisionalChart(args.profile, args.divisor);
});

/// Transit chart parameters — date invalidation is intentional (no keepAlive).
class TransitChartArgs {
  const TransitChartArgs({required this.profile, required this.date});

  final BirthProfile profile;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is TransitChartArgs &&
      other.profile.id == profile.id &&
      other.date == date;

  @override
  int get hashCode => Object.hash(profile.id, date);
}

final transitChartFamilyProvider = FutureProvider.autoDispose
    .family<VedicChartData, TransitChartArgs>((ref, args) {
  return ref
      .watch(chartRepositoryProvider)
      .getTransitChart(args.profile, args.date);
});

/// Panchang for (profile, date).
class PanchangArgs {
  const PanchangArgs({required this.profile, required this.date});

  final BirthProfile profile;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is PanchangArgs &&
      other.profile.id == profile.id &&
      other.date == date;

  @override
  int get hashCode => Object.hash(profile.id, date);
}

final panchangProvider = FutureProvider.autoDispose
    .family<PanchangData, PanchangArgs>((ref, args) {
  return ref
      .watch(chartRepositoryProvider)
      .getPanchang(args.profile, args.date);
});

// ---------------------------------------------------------------------------
// Active-profile convenience providers (used by the UI tabs).
// ---------------------------------------------------------------------------

/// D1 natal chart for the currently-active profile (null if no profile).
final vedicChartProvider = FutureProvider<VedicChartData?>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref.watch(natalChartProvider(profile).future);
});

/// Dasha for the currently-active profile.
final dashaProvider = FutureProvider<DashaData?>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref.watch(dashaChartProvider(profile).future);
});

/// Divisional chart by divisor for the currently-active profile.
final divisionalChartProvider =
    FutureProvider.family<VedicChartData?, int>((ref, divisor) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref.watch(
    divisionalChartFamilyProvider(
      DivisionalChartArgs(profile: profile, divisor: divisor),
    ).future,
  );
});

/// Transit "moment" (UTC). Defaults to now; updated by the transit screen.
final transitMomentProvider =
    StateProvider<DateTime>((_) => DateTime.now().toUtc());

final transitChartProvider = FutureProvider<VedicChartData?>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  final at = ref.watch(transitMomentProvider);
  return ref.watch(
    transitChartFamilyProvider(
      TransitChartArgs(profile: profile, date: at),
    ).future,
  );
});

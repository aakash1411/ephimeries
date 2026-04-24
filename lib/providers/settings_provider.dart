import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/app_settings.dart';
import '../domain/models/enums.dart';
import 'hive_providers.dart';

/// Reactive wrapper over the persisted [AppSettings] singleton.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final box = ref.watch(hiveBoxesProvider).settings;
    final existing = box.get(kSettingsKey);
    if (existing != null) return existing;
    final fresh = AppSettings();
    box.put(kSettingsKey, fresh);
    return fresh;
  }

  Future<void> _save(AppSettings next) async {
    final box = ref.read(hiveBoxesProvider).settings;
    await box.put(kSettingsKey, next);
    state = next;
  }

  Future<void> setChartStyle(ChartStyle style) =>
      _save(state.copyWith(chartStyle: style));

  Future<void> setAyanamsa(AyanamsaType ayanamsa) =>
      _save(state.copyWith(ayanamsa: ayanamsa));

  Future<void> setShowRetrograde(bool v) =>
      _save(state.copyWith(showRetrograde: v));

  Future<void> setShowAspectsOnChart(bool v) =>
      _save(state.copyWith(showAspectsOnChart: v));

  Future<void> setTheme(AppThemeMode theme) =>
      _save(state.copyWith(theme: theme));

  Future<void> setOnboardingCompleted(bool v) =>
      _save(state.copyWith(onboardingCompleted: v));

  Future<void> setNameLanguage(NameLanguage v) =>
      _save(state.copyWith(nameLanguage: v));

  Future<void> setDegreeFormat(DegreeFormat v) =>
      _save(state.copyWith(degreeFormat: v));

  Future<void> setAcceptedLegalVersion(int v) =>
      _save(state.copyWith(acceptedLegalVersion: v));

  Future<void> setAnalysisEntitled(bool v) =>
      _save(state.copyWith(analysisEntitled: v));
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

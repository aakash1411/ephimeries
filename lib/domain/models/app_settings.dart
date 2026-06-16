import 'package:hive/hive.dart';

import 'enums.dart';

part 'app_settings.g.dart';

/// User-adjustable app settings, persisted in Hive.
@HiveType(typeId: 20)
class AppSettings extends HiveObject {
  AppSettings({
    this.chartStyle = ChartStyle.northIndian,
    this.ayanamsa = AyanamsaType.lahiri,
    this.showRetrograde = true,
    this.showAspectsOnChart = false,
    this.theme = AppThemeMode.dark,
    this.onboardingCompleted = false,
    this.nameLanguage = NameLanguage.english,
    this.degreeFormat = DegreeFormat.dms,
    this.acceptedLegalVersion = 0,
  });

  @HiveField(0)
  ChartStyle chartStyle;

  @HiveField(1)
  AyanamsaType ayanamsa;

  @HiveField(2)
  bool showRetrograde;

  @HiveField(3)
  bool showAspectsOnChart;

  @HiveField(4)
  AppThemeMode theme;

  @HiveField(5, defaultValue: false)
  bool onboardingCompleted;

  @HiveField(6, defaultValue: NameLanguage.english)
  NameLanguage nameLanguage;

  @HiveField(7, defaultValue: DegreeFormat.dms)
  DegreeFormat degreeFormat;

  /// Legal-text version (see [kLegalTextVersion]) the user has accepted.
  /// `0` means never accepted. Bumping the constant forces a re-prompt.
  @HiveField(8, defaultValue: 0)
  int acceptedLegalVersion;

  AppSettings copyWith({
    ChartStyle? chartStyle,
    AyanamsaType? ayanamsa,
    bool? showRetrograde,
    bool? showAspectsOnChart,
    AppThemeMode? theme,
    bool? onboardingCompleted,
    NameLanguage? nameLanguage,
    DegreeFormat? degreeFormat,
    int? acceptedLegalVersion,
  }) {
    return AppSettings(
      chartStyle: chartStyle ?? this.chartStyle,
      ayanamsa: ayanamsa ?? this.ayanamsa,
      showRetrograde: showRetrograde ?? this.showRetrograde,
      showAspectsOnChart: showAspectsOnChart ?? this.showAspectsOnChart,
      theme: theme ?? this.theme,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      nameLanguage: nameLanguage ?? this.nameLanguage,
      degreeFormat: degreeFormat ?? this.degreeFormat,
      acceptedLegalVersion: acceptedLegalVersion ?? this.acceptedLegalVersion,
    );
  }
}

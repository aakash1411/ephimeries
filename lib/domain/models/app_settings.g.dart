// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 20;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      chartStyle: fields[0] as ChartStyle,
      ayanamsa: fields[1] as AyanamsaType,
      showRetrograde: fields[2] as bool,
      showAspectsOnChart: fields[3] as bool,
      theme: fields[4] as AppThemeMode,
      onboardingCompleted: fields[5] == null ? false : fields[5] as bool,
      nameLanguage:
          fields[6] == null ? NameLanguage.english : fields[6] as NameLanguage,
      degreeFormat:
          fields[7] == null ? DegreeFormat.dms : fields[7] as DegreeFormat,
      acceptedLegalVersion: fields[8] == null ? 0 : fields[8] as int,
      analysisEntitled: fields[9] == null ? true : fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.chartStyle)
      ..writeByte(1)
      ..write(obj.ayanamsa)
      ..writeByte(2)
      ..write(obj.showRetrograde)
      ..writeByte(3)
      ..write(obj.showAspectsOnChart)
      ..writeByte(4)
      ..write(obj.theme)
      ..writeByte(5)
      ..write(obj.onboardingCompleted)
      ..writeByte(6)
      ..write(obj.nameLanguage)
      ..writeByte(7)
      ..write(obj.degreeFormat)
      ..writeByte(8)
      ..write(obj.acceptedLegalVersion)
      ..writeByte(9)
      ..write(obj.analysisEntitled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

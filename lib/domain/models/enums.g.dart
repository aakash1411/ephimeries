// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZodiacSignAdapter extends TypeAdapter<ZodiacSign> {
  @override
  final int typeId = 1;

  @override
  ZodiacSign read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZodiacSign.aries;
      case 1:
        return ZodiacSign.taurus;
      case 2:
        return ZodiacSign.gemini;
      case 3:
        return ZodiacSign.cancer;
      case 4:
        return ZodiacSign.leo;
      case 5:
        return ZodiacSign.virgo;
      case 6:
        return ZodiacSign.libra;
      case 7:
        return ZodiacSign.scorpio;
      case 8:
        return ZodiacSign.sagittarius;
      case 9:
        return ZodiacSign.capricorn;
      case 10:
        return ZodiacSign.aquarius;
      case 11:
        return ZodiacSign.pisces;
      default:
        return ZodiacSign.aries;
    }
  }

  @override
  void write(BinaryWriter writer, ZodiacSign obj) {
    switch (obj) {
      case ZodiacSign.aries:
        writer.writeByte(0);
        break;
      case ZodiacSign.taurus:
        writer.writeByte(1);
        break;
      case ZodiacSign.gemini:
        writer.writeByte(2);
        break;
      case ZodiacSign.cancer:
        writer.writeByte(3);
        break;
      case ZodiacSign.leo:
        writer.writeByte(4);
        break;
      case ZodiacSign.virgo:
        writer.writeByte(5);
        break;
      case ZodiacSign.libra:
        writer.writeByte(6);
        break;
      case ZodiacSign.scorpio:
        writer.writeByte(7);
        break;
      case ZodiacSign.sagittarius:
        writer.writeByte(8);
        break;
      case ZodiacSign.capricorn:
        writer.writeByte(9);
        break;
      case ZodiacSign.aquarius:
        writer.writeByte(10);
        break;
      case ZodiacSign.pisces:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZodiacSignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlanetTypeAdapter extends TypeAdapter<PlanetType> {
  @override
  final int typeId = 2;

  @override
  PlanetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlanetType.sun;
      case 1:
        return PlanetType.moon;
      case 2:
        return PlanetType.mars;
      case 3:
        return PlanetType.mercury;
      case 4:
        return PlanetType.jupiter;
      case 5:
        return PlanetType.venus;
      case 6:
        return PlanetType.saturn;
      case 7:
        return PlanetType.rahu;
      case 8:
        return PlanetType.ketu;
      default:
        return PlanetType.sun;
    }
  }

  @override
  void write(BinaryWriter writer, PlanetType obj) {
    switch (obj) {
      case PlanetType.sun:
        writer.writeByte(0);
        break;
      case PlanetType.moon:
        writer.writeByte(1);
        break;
      case PlanetType.mars:
        writer.writeByte(2);
        break;
      case PlanetType.mercury:
        writer.writeByte(3);
        break;
      case PlanetType.jupiter:
        writer.writeByte(4);
        break;
      case PlanetType.venus:
        writer.writeByte(5);
        break;
      case PlanetType.saturn:
        writer.writeByte(6);
        break;
      case PlanetType.rahu:
        writer.writeByte(7);
        break;
      case PlanetType.ketu:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NakshatraAdapter extends TypeAdapter<Nakshatra> {
  @override
  final int typeId = 3;

  @override
  Nakshatra read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Nakshatra.ashwini;
      case 1:
        return Nakshatra.bharani;
      case 2:
        return Nakshatra.krittika;
      case 3:
        return Nakshatra.rohini;
      case 4:
        return Nakshatra.mrigashira;
      case 5:
        return Nakshatra.ardra;
      case 6:
        return Nakshatra.punarvasu;
      case 7:
        return Nakshatra.pushya;
      case 8:
        return Nakshatra.ashlesha;
      case 9:
        return Nakshatra.magha;
      case 10:
        return Nakshatra.purvaPhalguni;
      case 11:
        return Nakshatra.uttaraPhalguni;
      case 12:
        return Nakshatra.hasta;
      case 13:
        return Nakshatra.chitra;
      case 14:
        return Nakshatra.swati;
      case 15:
        return Nakshatra.vishakha;
      case 16:
        return Nakshatra.anuradha;
      case 17:
        return Nakshatra.jyeshtha;
      case 18:
        return Nakshatra.mula;
      case 19:
        return Nakshatra.purvaAshadha;
      case 20:
        return Nakshatra.uttaraAshadha;
      case 21:
        return Nakshatra.shravana;
      case 22:
        return Nakshatra.dhanishta;
      case 23:
        return Nakshatra.shatabhisha;
      case 24:
        return Nakshatra.purvaBhadrapada;
      case 25:
        return Nakshatra.uttaraBhadrapada;
      case 26:
        return Nakshatra.revati;
      default:
        return Nakshatra.ashwini;
    }
  }

  @override
  void write(BinaryWriter writer, Nakshatra obj) {
    switch (obj) {
      case Nakshatra.ashwini:
        writer.writeByte(0);
        break;
      case Nakshatra.bharani:
        writer.writeByte(1);
        break;
      case Nakshatra.krittika:
        writer.writeByte(2);
        break;
      case Nakshatra.rohini:
        writer.writeByte(3);
        break;
      case Nakshatra.mrigashira:
        writer.writeByte(4);
        break;
      case Nakshatra.ardra:
        writer.writeByte(5);
        break;
      case Nakshatra.punarvasu:
        writer.writeByte(6);
        break;
      case Nakshatra.pushya:
        writer.writeByte(7);
        break;
      case Nakshatra.ashlesha:
        writer.writeByte(8);
        break;
      case Nakshatra.magha:
        writer.writeByte(9);
        break;
      case Nakshatra.purvaPhalguni:
        writer.writeByte(10);
        break;
      case Nakshatra.uttaraPhalguni:
        writer.writeByte(11);
        break;
      case Nakshatra.hasta:
        writer.writeByte(12);
        break;
      case Nakshatra.chitra:
        writer.writeByte(13);
        break;
      case Nakshatra.swati:
        writer.writeByte(14);
        break;
      case Nakshatra.vishakha:
        writer.writeByte(15);
        break;
      case Nakshatra.anuradha:
        writer.writeByte(16);
        break;
      case Nakshatra.jyeshtha:
        writer.writeByte(17);
        break;
      case Nakshatra.mula:
        writer.writeByte(18);
        break;
      case Nakshatra.purvaAshadha:
        writer.writeByte(19);
        break;
      case Nakshatra.uttaraAshadha:
        writer.writeByte(20);
        break;
      case Nakshatra.shravana:
        writer.writeByte(21);
        break;
      case Nakshatra.dhanishta:
        writer.writeByte(22);
        break;
      case Nakshatra.shatabhisha:
        writer.writeByte(23);
        break;
      case Nakshatra.purvaBhadrapada:
        writer.writeByte(24);
        break;
      case Nakshatra.uttaraBhadrapada:
        writer.writeByte(25);
        break;
      case Nakshatra.revati:
        writer.writeByte(26);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NakshatraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChartStyleAdapter extends TypeAdapter<ChartStyle> {
  @override
  final int typeId = 4;

  @override
  ChartStyle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChartStyle.northIndian;
      case 1:
        return ChartStyle.southIndian;
      default:
        return ChartStyle.northIndian;
    }
  }

  @override
  void write(BinaryWriter writer, ChartStyle obj) {
    switch (obj) {
      case ChartStyle.northIndian:
        writer.writeByte(0);
        break;
      case ChartStyle.southIndian:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AyanamsaTypeAdapter extends TypeAdapter<AyanamsaType> {
  @override
  final int typeId = 5;

  @override
  AyanamsaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AyanamsaType.lahiri;
      case 1:
        return AyanamsaType.raman;
      case 2:
        return AyanamsaType.krishnamurti;
      case 3:
        return AyanamsaType.yukteshwar;
      default:
        return AyanamsaType.lahiri;
    }
  }

  @override
  void write(BinaryWriter writer, AyanamsaType obj) {
    switch (obj) {
      case AyanamsaType.lahiri:
        writer.writeByte(0);
        break;
      case AyanamsaType.raman:
        writer.writeByte(1);
        break;
      case AyanamsaType.krishnamurti:
        writer.writeByte(2);
        break;
      case AyanamsaType.yukteshwar:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyanamsaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 6;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.dark;
      case 1:
        return AppThemeMode.light;
      case 2:
        return AppThemeMode.system;
      default:
        return AppThemeMode.dark;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.dark:
        writer.writeByte(0);
        break;
      case AppThemeMode.light:
        writer.writeByte(1);
        break;
      case AppThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NameLanguageAdapter extends TypeAdapter<NameLanguage> {
  @override
  final int typeId = 7;

  @override
  NameLanguage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NameLanguage.english;
      case 1:
        return NameLanguage.sanskrit;
      default:
        return NameLanguage.english;
    }
  }

  @override
  void write(BinaryWriter writer, NameLanguage obj) {
    switch (obj) {
      case NameLanguage.english:
        writer.writeByte(0);
        break;
      case NameLanguage.sanskrit:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameLanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DegreeFormatAdapter extends TypeAdapter<DegreeFormat> {
  @override
  final int typeId = 8;

  @override
  DegreeFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DegreeFormat.dms;
      case 1:
        return DegreeFormat.decimal;
      default:
        return DegreeFormat.dms;
    }
  }

  @override
  void write(BinaryWriter writer, DegreeFormat obj) {
    switch (obj) {
      case DegreeFormat.dms:
        writer.writeByte(0);
        break;
      case DegreeFormat.decimal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DegreeFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

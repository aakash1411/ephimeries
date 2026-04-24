// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birth_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BirthProfileAdapter extends TypeAdapter<BirthProfile> {
  @override
  final int typeId = 10;

  @override
  BirthProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BirthProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      dateTime: fields[2] as DateTime,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      altitude: fields[5] as double,
      placeLabel: fields[6] as String,
      createdAt: fields[7] as DateTime,
      birthTimeUnknown: fields[8] == null ? false : fields[8] as bool,
      timezoneName: fields[9] == null ? 'UTC' : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BirthProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.altitude)
      ..writeByte(6)
      ..write(obj.placeLabel)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.birthTimeUnknown)
      ..writeByte(9)
      ..write(obj.timezoneName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

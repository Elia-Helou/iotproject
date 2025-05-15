// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantDataAdapter extends TypeAdapter<PlantData> {
  @override
  final int typeId = 0;

  @override
  PlantData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantData(
      moisture: fields[0] as double,
      light: fields[1] as double,
      rain: fields[2] as bool,
      pump: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlantData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.moisture)
      ..writeByte(1)
      ..write(obj.light)
      ..writeByte(2)
      ..write(obj.rain)
      ..writeByte(3)
      ..write(obj.pump);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

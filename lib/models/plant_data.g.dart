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
      temperature: fields[0] as double,
      humidity: fields[1] as double,
      moisture: fields[2] as double,
      waterLevel: fields[3] as double,
      airQuality: fields[4] as double,
      light: fields[5] as double,
      timestamp: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlantData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.humidity)
      ..writeByte(2)
      ..write(obj.moisture)
      ..writeByte(3)
      ..write(obj.waterLevel)
      ..writeByte(4)
      ..write(obj.airQuality)
      ..writeByte(5)
      ..write(obj.light)
      ..writeByte(6)
      ..write(obj.timestamp);
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drink_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrinkTemplateAdapter extends TypeAdapter<DrinkTemplate> {
  @override
  final int typeId = 3;

  @override
  DrinkTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrinkTemplate(
      id: fields[0] as String?,
      name: fields[1] as String,
      volumeMl: fields[2] as double,
      abvPercentage: fields[3] as double,
      category: fields[4] as String,
      rating: fields[5] as int,
      notes: fields[6] as String,
      isBuiltIn: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DrinkTemplate obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.volumeMl)
      ..writeByte(3)
      ..write(obj.abvPercentage)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isBuiltIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrinkTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

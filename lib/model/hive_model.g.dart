// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class hivemodelAdapter extends TypeAdapter<hive_model> {
  @override
  final int typeId = 1;

  @override
  hive_model read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return hive_model(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      dueDate: fields[3] as DateTime,
      priority: fields[4] as String,
      status: fields[5] as String,
      assignedUser: fields[6] as String,
      localId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, hive_model obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.assignedUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is hivemodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

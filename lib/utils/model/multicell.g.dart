// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multicell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MultiCellAdapter extends TypeAdapter<MultiCell> {
  @override
  final int typeId = 1;

  @override
  MultiCell read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultiCell()
      ..numbers = (fields[0] as List).cast<int>()
      ..isMarked = fields[1] as bool;
  }

  @override
  void write(BinaryWriter writer, MultiCell obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.numbers)
      ..writeByte(1)
      ..write(obj.isMarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiCellAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

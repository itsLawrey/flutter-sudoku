// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 2;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      fields[8] as Difficulty,
    )
      ..gameTable = (fields[0] as List)
          .map((dynamic e) => (e as List).cast<MultiCell>())
          .toList()
      ..selectedNumber = fields[2] as int?
      ..rowErrors = (fields[3] as List).cast<int>()
      ..colErrors = (fields[4] as List).cast<int>()
      ..clusterErrors = (fields[5] as List).cast<int>()
      ..currentErrors = fields[6] as int
      ..gameOver = fields[7] as bool
      ..startDate = fields[9] as DateTime
      ..elapsedSeconds = fields[10] as int
      ..gameName = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.gameTable)
      ..writeByte(2)
      ..write(obj.selectedNumber)
      ..writeByte(3)
      ..write(obj.rowErrors)
      ..writeByte(4)
      ..write(obj.colErrors)
      ..writeByte(5)
      ..write(obj.clusterErrors)
      ..writeByte(6)
      ..write(obj.currentErrors)
      ..writeByte(7)
      ..write(obj.gameOver)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.startDate)
      ..writeByte(10)
      ..write(obj.elapsedSeconds)
      ..writeByte(11)
      ..write(obj.gameName)
      ..writeByte(1)
      ..write(obj.fixedTableList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

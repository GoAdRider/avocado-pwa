// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordStatsAdapter extends TypeAdapter<WordStats> {
  @override
  final int typeId = 3;

  @override
  WordStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordStats(
      wordId: fields[0] as String,
      vocabularyFile: fields[1] as String,
      wrongCount: fields[2] as int,
      isWrongWord: fields[3] as bool,
      correctCount: fields[4] as int,
      lastStudyDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WordStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.wordId)
      ..writeByte(1)
      ..write(obj.vocabularyFile)
      ..writeByte(2)
      ..write(obj.wrongCount)
      ..writeByte(3)
      ..write(obj.isWrongWord)
      ..writeByte(4)
      ..write(obj.correctCount)
      ..writeByte(5)
      ..write(obj.lastStudyDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

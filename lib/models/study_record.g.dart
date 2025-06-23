// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyRecordAdapter extends TypeAdapter<StudyRecord> {
  @override
  final int typeId = 4;

  @override
  StudyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyRecord(
      id: fields[0] as String,
      wordId: fields[1] as String,
      vocabularyFile: fields[2] as String,
      studyDate: fields[3] as DateTime?,
      studyMode: fields[4] as String,
      gameType: fields[5] as String?,
      isCorrect: fields[6] as bool,
      score: fields[7] as int?,
      hintType: fields[8] as String?,
      hintsUsed: fields[9] as int,
      sessionStart: fields[10] as DateTime?,
      sessionEnd: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wordId)
      ..writeByte(2)
      ..write(obj.vocabularyFile)
      ..writeByte(3)
      ..write(obj.studyDate)
      ..writeByte(4)
      ..write(obj.studyMode)
      ..writeByte(5)
      ..write(obj.gameType)
      ..writeByte(6)
      ..write(obj.isCorrect)
      ..writeByte(7)
      ..write(obj.score)
      ..writeByte(8)
      ..write(obj.hintType)
      ..writeByte(9)
      ..write(obj.hintsUsed)
      ..writeByte(10)
      ..write(obj.sessionStart)
      ..writeByte(11)
      ..write(obj.sessionEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

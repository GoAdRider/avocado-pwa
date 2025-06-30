// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyProgressAdapter extends TypeAdapter<StudyProgress> {
  @override
  final int typeId = 9;

  @override
  StudyProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyProgress(
      sessionKey: fields[0] as String,
      currentIndex: fields[1] as int,
      totalWords: fields[2] as int,
      wordOrder: (fields[3] as List).cast<String>(),
      isShuffled: fields[4] as bool,
      lastStudyTime: fields[5] as DateTime,
      studyMode: fields[6] as String,
      targetMode: fields[7] as String,
      vocabularyFiles: (fields[8] as List).cast<String>(),
      posFilters: (fields[9] as List).cast<String>(),
      typeFilters: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudyProgress obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.sessionKey)
      ..writeByte(1)
      ..write(obj.currentIndex)
      ..writeByte(2)
      ..write(obj.totalWords)
      ..writeByte(3)
      ..write(obj.wordOrder)
      ..writeByte(4)
      ..write(obj.isShuffled)
      ..writeByte(5)
      ..write(obj.lastStudyTime)
      ..writeByte(6)
      ..write(obj.studyMode)
      ..writeByte(7)
      ..write(obj.targetMode)
      ..writeByte(8)
      ..write(obj.vocabularyFiles)
      ..writeByte(9)
      ..write(obj.posFilters)
      ..writeByte(10)
      ..write(obj.typeFilters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_word.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyWordAdapter extends TypeAdapter<VocabularyWord> {
  @override
  final int typeId = 0;

  @override
  VocabularyWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyWord(
      id: fields[0] as String,
      vocabularyFile: fields[1] as String,
      pos: fields[2] as String?,
      type: fields[3] as String?,
      targetVoca: fields[4] as String,
      targetPronunciation: fields[5] as String?,
      referenceVoca: fields[6] as String,
      targetDesc: fields[7] as String?,
      referenceDesc: fields[8] as String?,
      targetEx: fields[9] as String?,
      referenceEx: fields[10] as String?,
      importedDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyWord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vocabularyFile)
      ..writeByte(2)
      ..write(obj.pos)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.targetVoca)
      ..writeByte(5)
      ..write(obj.targetPronunciation)
      ..writeByte(6)
      ..write(obj.referenceVoca)
      ..writeByte(7)
      ..write(obj.targetDesc)
      ..writeByte(8)
      ..write(obj.referenceDesc)
      ..writeByte(9)
      ..write(obj.targetEx)
      ..writeByte(10)
      ..write(obj.referenceEx)
      ..writeByte(11)
      ..write(obj.importedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

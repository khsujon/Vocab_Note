// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabNoteAdapter extends TypeAdapter<VocabNote> {
  @override
  final int typeId = 0;

  @override
  VocabNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabNote(
      englishWord: fields[0] as String,
      banglaTranslation: fields[1] as String,
      partOfSpeech: fields[2] as String,
      synonyms: (fields[3] as List).cast<String>(),
      antonyms: (fields[4] as List).cast<String>(),
      createdDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VocabNote obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.englishWord)
      ..writeByte(1)
      ..write(obj.banglaTranslation)
      ..writeByte(2)
      ..write(obj.partOfSpeech)
      ..writeByte(3)
      ..write(obj.synonyms)
      ..writeByte(4)
      ..write(obj.antonyms)
      ..writeByte(5)
      ..write(obj.createdDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_question_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WrongQuestionModelAdapter extends TypeAdapter<WrongQuestionModel> {
  @override
  final int typeId = 10;

  @override
  WrongQuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WrongQuestionModel(
      id: fields[0] as String,
      tenseType: fields[1] as String,
      question: fields[2] as String,
      options: fields[3] as String,
      correctAnswer: fields[4] as String,
      explanation: fields[5] as String,
      userAnswer: fields[6] as String,
      difficulty: fields[7] as String,
      mode: fields[8] as String,
      savedAt: fields[9] as String,
      reviewCount: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WrongQuestionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tenseType)
      ..writeByte(2)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.options)
      ..writeByte(4)
      ..write(obj.correctAnswer)
      ..writeByte(5)
      ..write(obj.explanation)
      ..writeByte(6)
      ..write(obj.userAnswer)
      ..writeByte(7)
      ..write(obj.difficulty)
      ..writeByte(8)
      ..write(obj.mode)
      ..writeByte(9)
      ..write(obj.savedAt)
      ..writeByte(10)
      ..write(obj.reviewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WrongQuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

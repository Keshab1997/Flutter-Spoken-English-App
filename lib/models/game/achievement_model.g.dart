// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 4;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      unlocked: fields[3] as bool,
      unlockDate: fields[4] as DateTime?,
      icon: fields[5] as String,
      category: fields[6] as String,
      xpReward: fields[7] as int,
      coinReward: fields[8] as int,
      gameType: fields[9] as String?,
      condition: fields[10] as String?,
      order: fields[11] as int,
      rarity: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.unlocked)
      ..writeByte(4)
      ..write(obj.unlockDate)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.xpReward)
      ..writeByte(8)
      ..write(obj.coinReward)
      ..writeByte(9)
      ..write(obj.gameType)
      ..writeByte(10)
      ..write(obj.condition)
      ..writeByte(11)
      ..write(obj.order)
      ..writeByte(12)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

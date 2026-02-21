// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run build_runner build` to regenerate.

part of 'user_stats.dart';

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 2;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      totalPoints: fields[0] as int? ?? 0,
      currentStreak: fields[1] as int? ?? 0,
      bestStreak: fields[2] as int? ?? 0,
      lastReviewDate: fields[3] as DateTime?,
      totalCardsReviewed: fields[4] as int? ?? 0,
      totalSessions: fields[5] as int? ?? 0,
      earnedBadgeIds: (fields[6] as List?)?.cast<String>(),
      dailyPoints: (fields[7] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.totalPoints)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.bestStreak)
      ..writeByte(3)
      ..write(obj.lastReviewDate)
      ..writeByte(4)
      ..write(obj.totalCardsReviewed)
      ..writeByte(5)
      ..write(obj.totalSessions)
      ..writeByte(6)
      ..write(obj.earnedBadgeIds)
      ..writeByte(7)
      ..write(obj.dailyPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

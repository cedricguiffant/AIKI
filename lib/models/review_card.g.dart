// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run build_runner build` to regenerate.

part of 'review_card.dart';

class ReviewCardAdapter extends TypeAdapter<ReviewCard> {
  @override
  final int typeId = 0;

  @override
  ReviewCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewCard(
      id: fields[0] as String,
      deckId: fields[1] as String,
      front: fields[2] as String,
      back: fields[3] as String,
      extraFields: (fields[4] as List?)?.cast<String>() ?? [],
      easeFactor: fields[5] as double? ?? 2.5,
      intervalDays: fields[6] as int? ?? 0,
      reps: fields[7] as int? ?? 0,
      lapses: fields[8] as int? ?? 0,
      dueDate: fields[9] as DateTime?,
      lastReview: fields[10] as DateTime?,
      isKnown: fields[11] as bool? ?? false,
      audioPath: fields[12] as String?,
      imagePath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewCard obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.front)
      ..writeByte(3)
      ..write(obj.back)
      ..writeByte(4)
      ..write(obj.extraFields)
      ..writeByte(5)
      ..write(obj.easeFactor)
      ..writeByte(6)
      ..write(obj.intervalDays)
      ..writeByte(7)
      ..write(obj.reps)
      ..writeByte(8)
      ..write(obj.lapses)
      ..writeByte(9)
      ..write(obj.dueDate)
      ..writeByte(10)
      ..write(obj.lastReview)
      ..writeByte(11)
      ..write(obj.isKnown)
      ..writeByte(12)
      ..write(obj.audioPath)
      ..writeByte(13)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

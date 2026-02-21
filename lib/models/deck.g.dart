// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run build_runner build` to regenerate.

part of 'deck.dart';

class DeckAdapter extends TypeAdapter<Deck> {
  @override
  final int typeId = 1;

  @override
  Deck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Deck(
      id: fields[0] as String,
      name: fields[1] as String,
      totalCards: fields[2] as int,
      importedAt: fields[3] as DateTime?,
      lastSessionAt: fields[4] as DateTime?,
      description: fields[5] as String?,
      mediaDir: fields[6] as String?,
      aiSortCompleted: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Deck obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalCards)
      ..writeByte(3)
      ..write(obj.importedAt)
      ..writeByte(4)
      ..write(obj.lastSessionAt)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.mediaDir)
      ..writeByte(7)
      ..write(obj.aiSortCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

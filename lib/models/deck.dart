import 'package:hive/hive.dart';

part 'deck.g.dart';

/// Représente un deck importé depuis Anki (.apkg).
/// Represents an imported Anki deck (.apkg).
@HiveType(typeId: 1)
class Deck extends HiveObject {
  /// Identifiant unique du deck / Unique deck ID
  @HiveField(0)
  final String id;

  /// Nom du deck / Deck name
  @HiveField(1)
  final String name;

  /// Nombre total de cartes / Total card count
  @HiveField(2)
  final int totalCards;

  /// Date d'import / Import date
  @HiveField(3)
  final DateTime importedAt;

  /// Date de la dernière session de révision / Last review session date
  @HiveField(4)
  DateTime? lastSessionAt;

  /// Description optionnelle / Optional description
  @HiveField(5)
  final String? description;

  /// Chemin du répertoire média associé / Media directory path
  @HiveField(6)
  final String? mediaDir;

  /// Le tri AI a-t-il été effectué ? / Has AI sorting been done?
  @HiveField(7)
  bool aiSortCompleted;

  Deck({
    required this.id,
    required this.name,
    required this.totalCards,
    DateTime? importedAt,
    this.lastSessionAt,
    this.description,
    this.mediaDir,
    this.aiSortCompleted = false,
  }) : importedAt = importedAt ?? DateTime.now();

  Deck copyWith({
    String? id,
    String? name,
    int? totalCards,
    DateTime? importedAt,
    DateTime? lastSessionAt,
    String? description,
    String? mediaDir,
    bool? aiSortCompleted,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      totalCards: totalCards ?? this.totalCards,
      importedAt: importedAt ?? this.importedAt,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
      description: description ?? this.description,
      mediaDir: mediaDir ?? this.mediaDir,
      aiSortCompleted: aiSortCompleted ?? this.aiSortCompleted,
    );
  }
}

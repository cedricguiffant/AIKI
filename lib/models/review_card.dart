import 'package:hive/hive.dart';

part 'review_card.g.dart';

/// Carte de révision SRS — représente un mot/expression japonais à apprendre.
/// SRS review card — represents a Japanese word/expression to learn.
@HiveType(typeId: 0)
class ReviewCard extends HiveObject {
  /// Identifiant unique (note id from Anki or generated UUID)
  @HiveField(0)
  final String id;

  /// ID du deck parent / Parent deck ID
  @HiveField(1)
  final String deckId;

  /// Face avant : expression japonaise (kanji/kana)
  /// Front: Japanese expression (kanji/kana)
  @HiveField(2)
  final String front;

  /// Face arrière : traduction + lecture + notes
  /// Back: translation + reading + notes
  @HiveField(3)
  final String back;

  /// Champs supplémentaires extraits d'Anki (séparés par \x1f dans flds)
  /// Additional fields extracted from Anki
  @HiveField(4)
  final List<String> extraFields;

  // --- SRS Parameters (SM-2/Anki-like) ---

  /// Facteur de facilité (défaut 2.5) / Ease factor (default 2.5)
  @HiveField(5)
  double easeFactor;

  /// Intervalle en jours avant prochaine révision / Interval in days
  @HiveField(6)
  int intervalDays;

  /// Nombre de répétitions consécutives réussies / Consecutive successful reps
  @HiveField(7)
  int reps;

  /// Nombre de fois oubliée (réponse "Again") / Lapse count
  @HiveField(8)
  int lapses;

  /// Date d'échéance de la prochaine révision / Next review due date
  @HiveField(9)
  DateTime dueDate;

  /// Date de la dernière révision / Last review date
  @HiveField(10)
  DateTime? lastReview;

  /// Marquée comme connue par l'AI ou l'utilisateur / Marked as known
  @HiveField(11)
  bool isKnown;

  /// Chemin vers un fichier audio associé (optionnel)
  /// Path to associated audio file (optional)
  @HiveField(12)
  String? audioPath;

  /// Chemin vers une image associée (optionnelle)
  /// Path to associated image file (optional)
  @HiveField(13)
  String? imagePath;

  ReviewCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.extraFields = const [],
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.reps = 0,
    this.lapses = 0,
    DateTime? dueDate,
    this.lastReview,
    this.isKnown = false,
    this.audioPath,
    this.imagePath,
  }) : dueDate = dueDate ?? DateTime.now();

  /// La carte est-elle due pour révision ? / Is the card due for review?
  bool get isDue => DateTime.now().isAfter(dueDate) ||
      DateTime.now().isAtSameMomentAs(dueDate);

  /// Carte "jeune" = moins de 21 jours d'intervalle / Young card
  bool get isYoung => intervalDays < 21;

  /// Carte "mature" = 21+ jours d'intervalle / Mature card
  bool get isMature => intervalDays >= 21;

  /// Copie avec modifications / Copy with changes
  ReviewCard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    List<String>? extraFields,
    double? easeFactor,
    int? intervalDays,
    int? reps,
    int? lapses,
    DateTime? dueDate,
    DateTime? lastReview,
    bool? isKnown,
    String? audioPath,
    String? imagePath,
  }) {
    return ReviewCard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      extraFields: extraFields ?? this.extraFields,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      dueDate: dueDate ?? this.dueDate,
      lastReview: lastReview ?? this.lastReview,
      isKnown: isKnown ?? this.isKnown,
      audioPath: audioPath ?? this.audioPath,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

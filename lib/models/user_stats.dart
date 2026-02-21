import 'package:hive/hive.dart';

part 'user_stats.g.dart';

/// Statistiques globales de l'utilisateur (gamification).
/// Global user statistics (gamification).
@HiveType(typeId: 2)
class UserStats extends HiveObject {
  /// Points totaux accumulés / Total accumulated points
  @HiveField(0)
  int totalPoints;

  /// Streak quotidien actuel (jours consécutifs) / Current daily streak
  @HiveField(1)
  int currentStreak;

  /// Meilleur streak jamais atteint / Best streak ever
  @HiveField(2)
  int bestStreak;

  /// Date de la dernière révision (pour calcul streak)
  /// Last review date (for streak calculation)
  @HiveField(3)
  DateTime? lastReviewDate;

  /// Nombre total de cartes révisées / Total cards reviewed
  @HiveField(4)
  int totalCardsReviewed;

  /// Nombre total de sessions / Total sessions count
  @HiveField(5)
  int totalSessions;

  /// IDs des badges obtenus / Earned badge IDs
  @HiveField(6)
  List<String> earnedBadgeIds;

  /// Historique des points par jour {date_string: points}
  /// Daily points history
  @HiveField(7)
  Map<String, int> dailyPoints;

  UserStats({
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastReviewDate,
    this.totalCardsReviewed = 0,
    this.totalSessions = 0,
    List<String>? earnedBadgeIds,
    Map<String, int>? dailyPoints,
  })  : earnedBadgeIds = earnedBadgeIds ?? [],
        dailyPoints = dailyPoints ?? {};

  /// Ajoute des points et met à jour l'historique / Add points and update history
  void addPoints(int points) {
    totalPoints += points;
    final today = _todayKey();
    dailyPoints[today] = (dailyPoints[today] ?? 0) + points;
  }

  /// Met à jour le streak quotidien / Update daily streak
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastReviewDate == null) {
      currentStreak = 1;
    } else {
      final lastDate = DateTime(
        lastReviewDate!.year,
        lastReviewDate!.month,
        lastReviewDate!.day,
      );
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // Déjà révisé aujourd'hui / Already reviewed today
        return;
      } else if (diff == 1) {
        // Jour consécutif / Consecutive day
        currentStreak += 1;
      } else {
        // Streak cassé / Streak broken
        currentStreak = 1;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    lastReviewDate = now;
  }

  /// Vérifie si le streak est en danger (pas de révision aujourd'hui)
  /// Check if streak is at risk (no review today)
  bool get isStreakAtRisk {
    if (lastReviewDate == null || currentStreak == 0) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastReviewDate!.year,
      lastReviewDate!.month,
      lastReviewDate!.day,
    );
    return today.difference(lastDate).inDays >= 1;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

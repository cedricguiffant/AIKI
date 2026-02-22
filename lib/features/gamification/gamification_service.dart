import '../../models/badge.dart';
import '../../models/user_stats.dart';
import '../srs/srs_engine.dart';

/// Service de gamification : gère les points, streaks et badges.
/// Gamification service: manages points, streaks and badges.
class GamificationService {
  /// Points bonus pour streak quotidien / Daily streak bonus points
  static const int streakBonus = 50;

  /// Traite une réponse de révision : ajoute des points et met à jour le streak.
  /// Process a review response: add points and update streak.
  static UserStats processReview(
    UserStats stats,
    ReviewQuality quality, {
    bool isFirstReviewToday = false,
  }) {
    // Ajouter les points de la réponse / Add response points
    final points = SrsEngine.pointsForQuality(quality);
    stats.addPoints(points);

    // Mettre à jour le streak / Update streak
    stats.updateStreak();

    // Bonus streak (seulement à la première révision du jour)
    // Streak bonus (only on first review of the day)
    if (isFirstReviewToday && stats.currentStreak > 1) {
      stats.addPoints(streakBonus);
    }

    // Incrémenter compteur / Increment counter
    stats.totalCardsReviewed += 1;

    // Vérifier nouveaux badges / Check new badges
    final newBadges = AppBadges.getNewlyUnlocked(
      stats.totalPoints,
      stats.currentStreak,
      stats.earnedBadgeIds,
    );
    for (final badge in newBadges) {
      stats.earnedBadgeIds.add(badge.id);
    }

    return stats;
  }

  /// Termine une session : incrémente le compteur de sessions.
  /// End a session: increment session counter.
  static UserStats endSession(UserStats stats) {
    stats.totalSessions += 1;
    return stats;
  }

  /// Calcule le pourcentage de maîtrise d'un deck.
  /// Calculate mastery percentage for a deck.
  static int calculateMasteryPercent(
    int totalCards,
    int matureCards,
    int knownCards,
  ) {
    if (totalCards == 0) return 0;
    // Cartes matures = pleinement maîtrisées
    // Cartes connues mais pas matures = partiellement maîtrisées
    final score = (matureCards * 1.0 + knownCards * 0.5) / totalCards;
    return (score * 100).round().clamp(0, 100);
  }

  /// Retourne la liste des badges avec leur statut de déblocage.
  /// Return badges with their unlock status.
  static List<({AppBadge badge, bool unlocked})> getBadgeStatuses(
    UserStats stats,
  ) {
    return AppBadges.all
        .map((b) => (
              badge: b,
              unlocked: stats.earnedBadgeIds.contains(b.id),
            ))
        .toList();
  }
}

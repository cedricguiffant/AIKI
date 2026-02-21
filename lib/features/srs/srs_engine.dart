import 'dart:math';
import '../../models/review_card.dart';

/// Qualité de réponse pour l'algorithme SRS / Response quality for SRS
enum ReviewQuality {
  again(1), // Oublié / Forgotten
  hard(2),  // Difficile / Difficult
  good(3),  // Correct / Correct
  easy(4);  // Facile / Easy

  const ReviewQuality(this.value);
  final int value;
}

/// Moteur SRS basé sur SM-2 (variante Anki).
/// SM-2-based SRS engine (Anki variant).
///
/// Algorithme :
/// - easeFactor est ajusté selon la qualité de la réponse
/// - L'intervalle croît exponentiellement avec le ease factor
/// - Les lapses réinitialisent l'intervalle mais gardent un ease réduit
/// - Priorité de révision : lapses > young > mature (comme Anki)
class SrsEngine {
  /// Ease factor minimum pour éviter un effondrement / Minimum ease factor
  static const double minEaseFactor = 1.3;

  /// Intervalle max en jours (environ 10 ans) / Max interval
  static const int maxInterval = 3650;

  /// Calcule les nouveaux paramètres SRS après une réponse.
  /// Compute new SRS parameters after a response.
  static ReviewCard processAnswer(ReviewCard card, ReviewQuality quality) {
    double newEase = card.easeFactor;
    int newInterval = card.intervalDays;
    int newReps = card.reps;
    int newLapses = card.lapses;

    switch (quality) {
      case ReviewQuality.again:
        // Lapse : reset interval, diminue ease
        newLapses += 1;
        newReps = 0;
        newInterval = 1; // Revoir demain
        newEase = max(minEaseFactor, newEase - 0.20);
        break;

      case ReviewQuality.hard:
        // Réponse difficile : petit incrément, diminue ease légèrement
        newReps += 1;
        newEase = max(minEaseFactor, newEase - 0.15);
        if (newReps == 1) {
          newInterval = 1;
        } else if (newReps == 2) {
          newInterval = 4;
        } else {
          // Multiplie par ease * 1.2 (facteur hard = facteur réduit)
          newInterval = (card.intervalDays * newEase * 0.8).round();
        }
        break;

      case ReviewQuality.good:
        // Réponse correcte : progression normale
        newReps += 1;
        if (newReps == 1) {
          newInterval = 1;
        } else if (newReps == 2) {
          newInterval = 6;
        } else {
          newInterval = (card.intervalDays * newEase).round();
        }
        // Ease ne change pas pour "Good"
        break;

      case ReviewQuality.easy:
        // Réponse facile : progression accélérée, augmente ease
        newReps += 1;
        newEase += 0.15;
        if (newReps == 1) {
          newInterval = 3;
        } else if (newReps == 2) {
          newInterval = 8;
        } else {
          // Bonus easy : ease * 1.3
          newInterval = (card.intervalDays * newEase * 1.3).round();
        }
        break;
    }

    // Clamp interval / Limiter l'intervalle
    newInterval = newInterval.clamp(1, maxInterval);

    final now = DateTime.now();
    final newDueDate = DateTime(now.year, now.month, now.day)
        .add(Duration(days: newInterval));

    return card.copyWith(
      easeFactor: newEase,
      intervalDays: newInterval,
      reps: newReps,
      lapses: newLapses,
      dueDate: newDueDate,
      lastReview: now,
    );
  }

  /// Trie les cartes dues par priorité Anki : lapses > young > mature
  /// Sort due cards by Anki priority: lapses > young > mature
  static List<ReviewCard> sortDueCards(List<ReviewCard> cards) {
    final dueCards = cards.where((c) => c.isDue).toList();

    dueCards.sort((a, b) {
      // Priorité 1 : cartes avec lapses (oubliées récemment)
      if (a.lapses > 0 && b.lapses == 0) return -1;
      if (a.lapses == 0 && b.lapses > 0) return 1;

      // Priorité 2 : cartes jeunes avant matures
      if (a.isYoung && b.isMature) return -1;
      if (a.isMature && b.isYoung) return 1;

      // Priorité 3 : par date d'échéance (les plus en retard d'abord)
      return a.dueDate.compareTo(b.dueDate);
    });

    return dueCards;
  }

  /// Points de gamification selon la qualité / Gamification points by quality
  static int pointsForQuality(ReviewQuality quality) {
    switch (quality) {
      case ReviewQuality.again:
        return 5;
      case ReviewQuality.hard:
        return 10;
      case ReviewQuality.good:
        return 15;
      case ReviewQuality.easy:
        return 25;
    }
  }
}

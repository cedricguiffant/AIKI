import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_card.dart';
import '../services/database_service.dart';
import '../features/srs/srs_engine.dart';
import '../features/gamification/gamification_service.dart';
import 'stats_providers.dart';
import 'deck_providers.dart';

/// État d'une session de révision / Review session state
class ReviewSessionState {
  final List<ReviewCard> dueCards;
  final int currentIndex;
  final bool isFlipped;
  final bool isSessionComplete;
  final int pointsEarnedThisSession;
  final String deckId;

  const ReviewSessionState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.isSessionComplete = false,
    this.pointsEarnedThisSession = 0,
    this.deckId = '',
  });

  ReviewCard? get currentCard =>
      currentIndex < dueCards.length ? dueCards[currentIndex] : null;

  int get remaining => dueCards.length - currentIndex;
  int get total => dueCards.length;

  ReviewSessionState copyWith({
    List<ReviewCard>? dueCards,
    int? currentIndex,
    bool? isFlipped,
    bool? isSessionComplete,
    int? pointsEarnedThisSession,
    String? deckId,
  }) {
    return ReviewSessionState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      pointsEarnedThisSession:
          pointsEarnedThisSession ?? this.pointsEarnedThisSession,
      deckId: deckId ?? this.deckId,
    );
  }
}

/// Notifier pour la session de révision / Review session notifier
class ReviewSessionNotifier extends StateNotifier<ReviewSessionState> {
  final Ref _ref;

  ReviewSessionNotifier(this._ref) : super(const ReviewSessionState());

  /// Démarre une session de révision pour un deck
  /// Start a review session for a deck
  void startSession(String deckId) {
    final cards = DatabaseService.getDueCards(deckId);
    final sorted = SrsEngine.sortDueCards(cards);

    state = ReviewSessionState(
      dueCards: sorted,
      currentIndex: 0,
      isFlipped: false,
      isSessionComplete: sorted.isEmpty,
      deckId: deckId,
    );
  }

  /// Retourne la carte (affiche la réponse) / Flip the card (show answer)
  void flipCard() {
    state = state.copyWith(isFlipped: true);
  }

  /// Traite la réponse de l'utilisateur / Process user's answer
  Future<void> answerCard(ReviewQuality quality) async {
    final card = state.currentCard;
    if (card == null) return;

    // 1. Mettre à jour les paramètres SRS / Update SRS parameters
    final updatedCard = SrsEngine.processAnswer(card, quality);
    await DatabaseService.saveCard(updatedCard);

    // 2. Mettre à jour les stats de gamification
    // Update gamification stats
    final stats = DatabaseService.getUserStats();
    final isFirstToday = stats.lastReviewDate == null ||
        stats.lastReviewDate!.day != DateTime.now().day ||
        stats.lastReviewDate!.month != DateTime.now().month ||
        stats.lastReviewDate!.year != DateTime.now().year;

    final updatedStats = GamificationService.processReview(
      stats,
      quality,
      isFirstReviewToday: isFirstToday,
    );
    await DatabaseService.saveUserStats(updatedStats);
    _ref.read(userStatsProvider.notifier).refresh();

    // 3. Calculer les points gagnés / Calculate points earned
    final points = SrsEngine.pointsForQuality(quality);
    final totalPoints = state.pointsEarnedThisSession + points;

    // 4. Passer à la carte suivante / Move to next card
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.dueCards.length) {
      // Session terminée / Session complete
      final endStats = GamificationService.endSession(
        DatabaseService.getUserStats(),
      );
      await DatabaseService.saveUserStats(endStats);
      _ref.read(userStatsProvider.notifier).refresh();
      _ref.read(decksProvider.notifier).updateLastSession(state.deckId);

      state = state.copyWith(
        currentIndex: nextIndex,
        isFlipped: false,
        isSessionComplete: true,
        pointsEarnedThisSession: totalPoints,
      );
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        isFlipped: false,
        pointsEarnedThisSession: totalPoints,
      );
    }
  }

  /// Override manuel : marquer comme connu / Manual override: mark as known
  Future<void> markAsKnown() async {
    final card = state.currentCard;
    if (card == null) return;

    final updated = card.copyWith(
      isKnown: true,
      intervalDays: 30,
      dueDate: DateTime.now().add(const Duration(days: 30)),
    );
    await DatabaseService.saveCard(updated);

    // Passer à la suivante / Move to next
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.dueCards.length) {
      state = state.copyWith(
        currentIndex: nextIndex,
        isFlipped: false,
        isSessionComplete: true,
      );
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        isFlipped: false,
      );
    }
  }
}

final reviewSessionProvider =
    StateNotifierProvider<ReviewSessionNotifier, ReviewSessionState>((ref) {
  return ReviewSessionNotifier(ref);
});

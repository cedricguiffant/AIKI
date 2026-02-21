import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deck.dart';
import '../models/review_card.dart';
import '../services/database_service.dart';
import '../services/anki_parser.dart';
import '../features/ai_sort/ai_sorter.dart';
import '../features/gamification/gamification_service.dart';
import '../utils/constants.dart';

/// État de l'import de deck / Deck import state
class DeckImportState {
  final bool isImporting;
  final String? statusMessage;
  final double progress;
  final String? error;

  const DeckImportState({
    this.isImporting = false,
    this.statusMessage,
    this.progress = 0,
    this.error,
  });

  DeckImportState copyWith({
    bool? isImporting,
    String? statusMessage,
    double? progress,
    String? error,
  }) {
    return DeckImportState(
      isImporting: isImporting ?? this.isImporting,
      statusMessage: statusMessage ?? this.statusMessage,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

/// Provider de la liste des decks / Deck list provider
class DecksNotifier extends StateNotifier<List<Deck>> {
  DecksNotifier() : super(DatabaseService.getAllDecks());

  void refresh() {
    state = DatabaseService.getAllDecks();
  }

  Future<void> deleteDeck(String deckId) async {
    await DatabaseService.deleteDeck(deckId);
    refresh();
  }

  Future<void> updateLastSession(String deckId) async {
    final deck = DatabaseService.getDeck(deckId);
    if (deck != null) {
      final updated = deck.copyWith(lastSessionAt: DateTime.now());
      await DatabaseService.saveDeck(updated);
      refresh();
    }
  }
}

final decksProvider =
    StateNotifierProvider<DecksNotifier, List<Deck>>((ref) {
  return DecksNotifier();
});

/// Provider d'état d'import / Import state provider
class DeckImportNotifier extends StateNotifier<DeckImportState> {
  final Ref _ref;

  DeckImportNotifier(this._ref) : super(const DeckImportState());

  /// Importe un fichier .apkg / Import an .apkg file
  Future<void> importApkg(String filePath) async {
    state = const DeckImportState(
      isImporting: true,
      statusMessage: 'Lecture du fichier...',
      progress: 0.1,
    );

    try {
      // 1. Parser le fichier Anki / Parse the Anki file
      state = state.copyWith(
        statusMessage: 'Extraction des cartes...',
        progress: 0.3,
      );
      final result = await AnkiParser.importApkg(filePath);

      // 2. Sauvegarder le deck et les cartes / Save deck and cards
      state = state.copyWith(
        statusMessage: 'Sauvegarde en base...',
        progress: 0.6,
      );
      await DatabaseService.saveDeck(result.deck);
      await DatabaseService.saveCards(result.cards);

      // 3. Lancer le tri AI si la clé est disponible
      // Launch AI sorting if key is available
      final apiKey = DatabaseService.geminiApiKey;
      if (apiKey != null && apiKey.isNotEmpty) {
        state = state.copyWith(
          statusMessage: 'Tri AI en cours...',
          progress: 0.7,
        );
        await _runAiSort(result.deck.id, result.cards, apiKey);
      }

      state = state.copyWith(
        statusMessage: 'Import terminé !',
        progress: 1.0,
      );

      // Rafraîchir la liste des decks / Refresh deck list
      _ref.read(decksProvider.notifier).refresh();

      // Petit délai pour montrer le succès
      await Future.delayed(const Duration(milliseconds: 500));
      state = const DeckImportState();
    } catch (e) {
      state = DeckImportState(
        isImporting: false,
        error: 'Erreur d\'import : $e',
      );
    }
  }

  /// Exécute le tri AI sur les cartes importées / Run AI sort on imported cards
  Future<void> _runAiSort(
    String deckId,
    List<ReviewCard> cards,
    String apiKey,
  ) async {
    final sorter = AiSorter(apiKey: apiKey);

    await for (final result in sorter.sortBatch(
      cards,
      onProgress: (current, total) {
        state = state.copyWith(
          statusMessage: 'Tri AI : $current/$total',
          progress: 0.7 + (0.25 * current / total),
        );
      },
    )) {
      // Mettre à jour la carte selon le résultat AI
      // Update card based on AI result
      final card = DatabaseService.getCard(result.cardId);
      if (card != null) {
        final updated = card.copyWith(
          isKnown: result.isKnown,
          intervalDays: result.isKnown
              ? AppConstants.knownCardIntervalDays
              : AppConstants.newCardIntervalDays,
          dueDate: result.isKnown
              ? DateTime.now().add(
                  const Duration(days: AppConstants.knownCardIntervalDays),
                )
              : DateTime.now(),
        );
        await DatabaseService.saveCard(updated);
      }
    }

    // Marquer le tri AI comme terminé / Mark AI sort as done
    final deck = DatabaseService.getDeck(deckId);
    if (deck != null) {
      await DatabaseService.saveDeck(deck.copyWith(aiSortCompleted: true));
    }
  }

  void clearError() {
    state = const DeckImportState();
  }
}

final deckImportProvider =
    StateNotifierProvider<DeckImportNotifier, DeckImportState>((ref) {
  return DeckImportNotifier(ref);
});

/// Provider qui retourne les infos d'un deck avec ses stats
/// Provider returning deck info with stats
final deckStatsProvider =
    Provider.family<({int dueCount, int masteryPercent}), String>(
  (ref, deckId) {
    final cards = DatabaseService.getCardsForDeck(deckId);
    final dueCount = cards.where((c) => c.isDue).length;
    final matureCount = cards.where((c) => c.isMature).length;
    final knownCount = cards.where((c) => c.isKnown && !c.isMature).length;
    final masteryPercent = GamificationService.calculateMasteryPercent(
      cards.length,
      matureCount,
      knownCount,
    );
    return (dueCount: dueCount, masteryPercent: masteryPercent);
  },
);

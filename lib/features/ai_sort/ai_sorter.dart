import 'package:google_generative_ai/google_generative_ai.dart';

import '../../models/review_card.dart';

/// Résultat du tri AI pour une carte / AI sort result for a card
class AiSortResult {
  final String cardId;
  final bool isKnown;
  final String exampleSentence;
  final String translation;
  final String reason;

  const AiSortResult({
    required this.cardId,
    required this.isKnown,
    required this.exampleSentence,
    required this.translation,
    required this.reason,
  });
}

/// Service de tri AI utilisant Gemini pour évaluer si un mot
/// est probablement connu d'un apprenant débutant.
/// AI sorting service using Gemini to evaluate if a word
/// is likely known by a beginner learner.
class AiSorter {
  final GenerativeModel _model;

  AiSorter({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  /// Trie une carte : détermine si le mot est probablement connu.
  /// Sort a card: determine if the word is likely known.
  Future<AiSortResult> sortCard(ReviewCard card) async {
    final prompt = '''
Génère une phrase très simple en japonais utilisant uniquement le mot/phrase '${card.front}' et traduis-la en français.
Puis dis si un apprenant débutant (N5-N4 JLPT) devrait déjà connaître ce mot (oui/non + raison courte).

Réponds EXACTEMENT dans ce format :
PHRASE_JP: [phrase en japonais]
PHRASE_FR: [traduction en français]
CONNU: [oui/non]
RAISON: [raison courte]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parseResponse(card.id, text);
    } catch (e) {
      // En cas d'erreur API, traiter comme "non connu" par défaut
      // On API error, default to "unknown"
      return AiSortResult(
        cardId: card.id,
        isKnown: false,
        exampleSentence: '',
        translation: '',
        reason: 'Erreur API: $e',
      );
    }
  }

  /// Trie un lot de cartes avec un délai entre les requêtes.
  /// Sort a batch of cards with delay between requests.
  Stream<AiSortResult> sortBatch(
    List<ReviewCard> cards, {
    Duration delay = const Duration(milliseconds: 500),
    void Function(int current, int total)? onProgress,
  }) async* {
    for (int i = 0; i < cards.length; i++) {
      onProgress?.call(i + 1, cards.length);
      yield await sortCard(cards[i]);

      // Rate limiting : pause entre les requêtes
      if (i < cards.length - 1) {
        await Future.delayed(delay);
      }
    }
  }

  /// Parse la réponse de Gemini / Parse Gemini response
  AiSortResult _parseResponse(String cardId, String text) {
    String phraseJp = '';
    String phraseFr = '';
    bool isKnown = false;
    String reason = '';

    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('PHRASE_JP:')) {
        phraseJp = trimmed.substring('PHRASE_JP:'.length).trim();
      } else if (trimmed.startsWith('PHRASE_FR:')) {
        phraseFr = trimmed.substring('PHRASE_FR:'.length).trim();
      } else if (trimmed.startsWith('CONNU:')) {
        final value = trimmed.substring('CONNU:'.length).trim().toLowerCase();
        isKnown = value == 'oui' || value == 'yes';
      } else if (trimmed.startsWith('RAISON:')) {
        reason = trimmed.substring('RAISON:'.length).trim();
      }
    }

    return AiSortResult(
      cardId: cardId,
      isKnown: isKnown,
      exampleSentence: phraseJp,
      translation: phraseFr,
      reason: reason,
    );
  }
}

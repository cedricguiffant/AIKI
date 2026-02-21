import 'package:hive_flutter/hive_flutter.dart';

import '../models/review_card.dart';
import '../models/deck.dart';
import '../models/user_stats.dart';

/// Service de base de données locale utilisant Hive.
/// Local database service using Hive.
///
/// Hive est choisi pour sa rapidité et simplicité :
/// - Pas besoin de schema SQL
/// - Sérialisation binaire rapide
/// - API simple pour CRUD
class DatabaseService {
  static const String _decksBox = 'decks';
  static const String _cardsBox = 'cards';
  static const String _statsBox = 'stats';
  static const String _settingsBox = 'settings';
  static const String _statsKey = 'userStats';

  /// Initialise Hive et enregistre les adapters.
  /// Initialize Hive and register adapters.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Enregistrer les adapters de types / Register type adapters
    Hive.registerAdapter(ReviewCardAdapter());
    Hive.registerAdapter(DeckAdapter());
    Hive.registerAdapter(UserStatsAdapter());

    // Ouvrir les boxes / Open boxes
    await Hive.openBox<Deck>(_decksBox);
    await Hive.openBox<ReviewCard>(_cardsBox);
    await Hive.openBox<UserStats>(_statsBox);
    await Hive.openBox<dynamic>(_settingsBox);
  }

  // --- Decks ---

  static Box<Deck> get _deckBox => Hive.box<Deck>(_decksBox);

  /// Récupère tous les decks / Get all decks
  static List<Deck> getAllDecks() => _deckBox.values.toList();

  /// Récupère un deck par ID / Get deck by ID
  static Deck? getDeck(String id) => _deckBox.get(id);

  /// Sauvegarde un deck / Save a deck
  static Future<void> saveDeck(Deck deck) => _deckBox.put(deck.id, deck);

  /// Supprime un deck et toutes ses cartes / Delete a deck and all its cards
  static Future<void> deleteDeck(String deckId) async {
    await _deckBox.delete(deckId);
    // Supprimer toutes les cartes du deck / Delete all cards in deck
    final cardBox = _cardBox;
    final keysToDelete = cardBox.keys
        .where((key) => cardBox.get(key)?.deckId == deckId)
        .toList();
    await cardBox.deleteAll(keysToDelete);
  }

  // --- Cards ---

  static Box<ReviewCard> get _cardBox => Hive.box<ReviewCard>(_cardsBox);

  /// Récupère toutes les cartes d'un deck / Get all cards for a deck
  static List<ReviewCard> getCardsForDeck(String deckId) {
    return _cardBox.values.where((c) => c.deckId == deckId).toList();
  }

  /// Récupère les cartes dues d'un deck / Get due cards for a deck
  static List<ReviewCard> getDueCards(String deckId) {
    return _cardBox.values
        .where((c) => c.deckId == deckId && c.isDue)
        .toList();
  }

  /// Sauvegarde une carte / Save a card
  static Future<void> saveCard(ReviewCard card) =>
      _cardBox.put(card.id, card);

  /// Sauvegarde un lot de cartes / Save a batch of cards
  static Future<void> saveCards(List<ReviewCard> cards) async {
    final entries = {for (final c in cards) c.id: c};
    await _cardBox.putAll(entries);
  }

  /// Récupère une carte par ID / Get card by ID
  static ReviewCard? getCard(String id) => _cardBox.get(id);

  /// Compte les cartes matures d'un deck / Count mature cards in a deck
  static int countMatureCards(String deckId) {
    return _cardBox.values
        .where((c) => c.deckId == deckId && c.isMature)
        .length;
  }

  /// Compte les cartes connues d'un deck / Count known cards in a deck
  static int countKnownCards(String deckId) {
    return _cardBox.values
        .where((c) => c.deckId == deckId && c.isKnown)
        .length;
  }

  // --- User Stats ---

  static Box<UserStats> get _statsBox2 => Hive.box<UserStats>(_statsBox);

  /// Récupère les stats utilisateur (crée si inexistant)
  /// Get user stats (create if not exists)
  static UserStats getUserStats() {
    return _statsBox2.get(_statsKey) ?? UserStats();
  }

  /// Sauvegarde les stats utilisateur / Save user stats
  static Future<void> saveUserStats(UserStats stats) =>
      _statsBox2.put(_statsKey, stats);

  // --- Settings ---

  static Box<dynamic> get _settingsBoxInstance =>
      Hive.box<dynamic>(_settingsBox);

  /// Récupère une valeur de paramètre / Get a setting value
  static T? getSetting<T>(String key) =>
      _settingsBoxInstance.get(key) as T?;

  /// Sauvegarde une valeur de paramètre / Save a setting value
  static Future<void> saveSetting(String key, dynamic value) =>
      _settingsBoxInstance.put(key, value);

  /// Clé API Gemini / Gemini API key
  static String? get geminiApiKey => getSetting<String>('geminiApiKey');
  static Future<void> setGeminiApiKey(String key) =>
      saveSetting('geminiApiKey', key);

  /// Mode sombre / Dark mode
  static bool get isDarkMode => getSetting<bool>('darkMode') ?? false;
  static Future<void> setDarkMode(bool value) =>
      saveSetting('darkMode', value);
}

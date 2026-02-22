import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/review_card.dart';
import '../models/deck.dart';

/// Résultat de l'import d'un fichier .apkg / Import result
class AnkiImportResult {
  final Deck deck;
  final List<ReviewCard> cards;
  final int mediaFilesCount;

  const AnkiImportResult({
    required this.deck,
    required this.cards,
    this.mediaFilesCount = 0,
  });
}

/// Service de parsing des fichiers Anki (.apkg).
/// Anki file parser service (.apkg).
///
/// Un fichier .apkg est un ZIP contenant :
/// - collection.anki2 : base SQLite avec les notes et cartes
/// - media : fichier JSON mappant les noms de fichiers média
/// - 0, 1, 2... : fichiers média eux-mêmes
class AnkiParser {
  static const _uuid = Uuid();
  static const _fieldSeparator = '\x1f'; // Séparateur de champs Anki

  /// Importe un fichier .apkg et retourne les cartes extraites.
  /// Import an .apkg file and return extracted cards.
  static Future<AnkiImportResult> importApkg(String filePath) async {
    // 1. Lire et dézipper le fichier / Read and unzip
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 2. Trouver collection.anki2 / Find the SQLite database
    final anki2File = archive.files.firstWhere(
      (f) => f.name == 'collection.anki2' || f.name.endsWith('.anki2'),
      orElse: () => throw const FormatException(
        'Fichier collection.anki2 introuvable dans le .apkg / '
        'collection.anki2 not found in .apkg',
      ),
    );

    // 3. Écrire le fichier SQLite temporairement / Write temp SQLite file
    final tempDir = await getTemporaryDirectory();
    final deckId = _uuid.v4();
    final dbPath = p.join(tempDir.path, 'anki_$deckId.db');
    final dbFile = File(dbPath);
    await dbFile.writeAsBytes(anki2File.content as List<int>);

    // 4. Extraire les médias / Extract media files
    String? mediaDir;
    int mediaCount = 0;
    try {
      final result = await _extractMedia(archive, deckId);
      mediaDir = result.$1;
      mediaCount = result.$2;
    } catch (_) {
      // Les médias sont optionnels / Media is optional
    }

    // 5. Ouvrir la base SQLite et extraire les données / Open SQLite and extract
    final db = await openDatabase(dbPath, readOnly: true);
    try {
      final cards = await _extractCards(db, deckId);
      final deckName = await _extractDeckName(db);

      final deck = Deck(
        id: deckId,
        name: deckName,
        totalCards: cards.length,
        mediaDir: mediaDir,
      );

      return AnkiImportResult(
        deck: deck,
        cards: cards,
        mediaFilesCount: mediaCount,
      );
    } finally {
      await db.close();
      // Nettoyage du fichier temporaire / Cleanup temp file
      try {
        await dbFile.delete();
      } catch (_) {}
    }
  }

  /// Extrait les cartes depuis la base SQLite Anki.
  /// Extract cards from Anki SQLite database.
  static Future<List<ReviewCard>> _extractCards(
    Database db,
    String deckId,
  ) async {
    // Anki schema : notes table contient flds (fields séparés par \x1f)
    // cards table lie les notes aux cartes
    final notes = await db.rawQuery('''
      SELECT n.id, n.flds, n.tags
      FROM notes n
      ORDER BY n.id
    ''');

    final cards = <ReviewCard>[];

    for (final note in notes) {
      final noteId = note['id'].toString();
      final flds = (note['flds'] as String?) ?? '';
      final fields = flds.split(_fieldSeparator);

      if (fields.isEmpty) continue;

      // Premier champ = front (japonais), reste = back
      final front = _cleanHtml(fields[0]);
      if (front.trim().isEmpty) continue;

      final back = fields.length > 1
          ? _cleanHtml(fields.sublist(1).join('\n'))
          : '';
      final extraFields = fields.length > 2
          ? fields.sublist(2).map(_cleanHtml).toList()
          : <String>[];

      cards.add(ReviewCard(
        id: '${deckId}_$noteId',
        deckId: deckId,
        front: front,
        back: back,
        extraFields: extraFields,
      ));
    }

    return cards;
  }

  /// Extrait le nom du deck depuis les métadonnées Anki.
  /// Extract deck name from Anki metadata.
  static Future<String> _extractDeckName(Database db) async {
    try {
      final result = await db.rawQuery('SELECT decks FROM col LIMIT 1');
      if (result.isNotEmpty) {
        final decksJson = result.first['decks'] as String?;
        if (decksJson != null) {
          final decks = json.decode(decksJson) as Map<String, dynamic>;
          // Prendre le premier deck non-default
          for (final entry in decks.entries) {
            final name = (entry.value as Map<String, dynamic>)['name'] as String?;
            if (name != null && name != 'Default') {
              return name;
            }
          }
        }
      }
    } catch (_) {
      // Fallback si le schema est différent
    }
    return 'Deck importé';
  }

  /// Extrait les fichiers média du ZIP.
  /// Extract media files from ZIP archive.
  static Future<(String, int)> _extractMedia(
    Archive archive,
    String deckId,
  ) async {
    // Chercher le fichier 'media' (JSON mapping)
    final mediaMapFile = archive.files
        .where((f) => f.name == 'media')
        .firstOrNull;

    if (mediaMapFile == null) return ('', 0);

    final mediaJson = utf8.decode(mediaMapFile.content as List<int>);
    final mediaMap = json.decode(mediaJson) as Map<String, dynamic>;

    if (mediaMap.isEmpty) return ('', 0);

    // Créer le répertoire média / Create media directory
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDir.path, 'media', deckId));
    await mediaDir.create(recursive: true);

    int count = 0;
    for (final entry in mediaMap.entries) {
      final archiveIndex = entry.key; // "0", "1", "2"...
      final originalName = entry.value as String;

      final archiveFile = archive.files
          .where((f) => f.name == archiveIndex)
          .firstOrNull;

      if (archiveFile != null) {
        final outFile = File(p.join(mediaDir.path, originalName));
        await outFile.writeAsBytes(archiveFile.content as List<int>);
        count++;
      }
    }

    return (mediaDir.path, count);
  }

  /// Nettoie le HTML basique des champs Anki / Clean basic HTML from Anki fields
  static String _cleanHtml(String input) {
    // Supprimer les tags HTML courants
    return input
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<div[^>]*>'), '\n')
        .replaceAll(RegExp(r'</div>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}

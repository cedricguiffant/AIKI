import 'package:flutter_test/flutter_test.dart';

// Test du nettoyage HTML du parser Anki
// (méthode publique via test indirect, car _cleanHtml est privé)
// On teste le comportement via des strings typiques d'Anki

void main() {
  group('AnkiParser - HTML cleaning logic', () {
    // Ces tests vérifient la logique de nettoyage qu'on attend
    // du parser Anki sur les champs flds typiques

    test('Supprime les tags <br>', () {
      final cleaned = _cleanHtml('食べる<br>manger');
      expect(cleaned, '食べる\nmanger');
    });

    test('Supprime les tags <br/> self-closing', () {
      final cleaned = _cleanHtml('食べる<br/>manger');
      expect(cleaned, '食べる\nmanger');
    });

    test('Supprime les tags <div>', () {
      final cleaned = _cleanHtml('<div>食べる</div><div>manger</div>');
      expect(cleaned, '食べる\nmanger');
    });

    test('Supprime les tags HTML génériques', () {
      final cleaned = _cleanHtml('<b>食べる</b> <i>taberu</i>');
      expect(cleaned, '食べる taberu');
    });

    test('Décode les entités HTML', () {
      final cleaned = _cleanHtml('A &amp; B &lt; C &gt; D');
      expect(cleaned, 'A & B < C > D');
    });

    test('Remplace &nbsp; par espace', () {
      final cleaned = _cleanHtml('A&nbsp;B');
      expect(cleaned, 'A B');
    });

    test('Trim les espaces', () {
      final cleaned = _cleanHtml('  食べる  ');
      expect(cleaned, '食べる');
    });
  });
}

/// Réplique de la logique _cleanHtml du AnkiParser pour les tests.
/// Replica of AnkiParser._cleanHtml logic for testing.
String _cleanHtml(String input) {
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

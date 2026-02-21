import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/deck_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../services/database_service.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/common_widgets.dart';
import '../../review_session/screens/review_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'import_screen.dart';

/// Écran d'accueil : liste des decks importés.
/// Home screen: list of imported decks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);
    final stats = ref.watch(userStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kana SRS'),
        actions: [
          // Streak indicator
          if (stats.currentStreak > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${stats.currentStreak}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Profil
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: decks.isEmpty
          ? EmptyState(
              icon: Icons.library_books_outlined,
              message: 'Aucun deck importé.\nAppuyez sur + pour commencer !',
              action: FilledButton.icon(
                onPressed: () => _navigateToImport(context),
                icon: const Icon(Icons.add),
                label: const Text('Importer un deck'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                final deckStats = ref.watch(deckStatsProvider(deck.id));

                return DeckListTile(
                  name: deck.name,
                  cardCount: deck.totalCards,
                  dueCount: deckStats.dueCount,
                  masteryPercent: deckStats.masteryPercent,
                  lastSession: deck.lastSessionAt?.toReadableDate(),
                  onTap: () => _navigateToReview(context, deck.id, deck.name),
                  onDelete: () => _confirmDelete(context, ref, deck.id, deck.name),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToImport(context),
        tooltip: 'Importer un deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportScreen()),
    );
  }

  void _navigateToReview(
    BuildContext context,
    String deckId,
    String deckName,
  ) {
    final dueCards = DatabaseService.getDueCards(deckId);
    if (dueCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune carte à réviser pour le moment')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(deckId: deckId, deckName: deckName),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String deckId,
    String deckName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce deck ?'),
        content: Text(
          'Le deck "$deckName" et toutes ses cartes seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(decksProvider.notifier).deleteDeck(deckId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

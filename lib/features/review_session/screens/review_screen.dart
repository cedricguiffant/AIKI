import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/review_providers.dart';
import '../../../utils/constants.dart';
import '../widgets/flip_card.dart';
import '../widgets/quality_buttons.dart';

/// Écran de session de révision avec flip card et boutons SRS.
/// Review session screen with flip card and SRS buttons.
class ReviewScreen extends ConsumerStatefulWidget {
  final String deckId;
  final String deckName;

  const ReviewScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Démarrer la session / Start session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewSessionProvider.notifier).startSession(widget.deckId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(reviewSessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          // Compteur de cartes / Card counter
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${session.total - session.remaining}/${session.total}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: session.isSessionComplete
          ? _buildSessionComplete(context, session)
          : _buildReviewCard(context, session),
    );
  }

  /// Affiche la carte en cours de révision / Show current review card
  Widget _buildReviewCard(BuildContext context, ReviewSessionState session) {
    final card = session.currentCard;
    if (card == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de progression / Progress bar
            LinearProgressIndicator(
              value: session.total > 0
                  ? (session.total - session.remaining) / session.total
                  : 0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),

            // Compteur texte / Text counter
            Text(
              '${session.remaining} carte(s) restante(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Carte flip / Flip card
            Expanded(
              child: GestureDetector(
                onTap: session.isFlipped
                    ? null
                    : () => ref
                        .read(reviewSessionProvider.notifier)
                        .flipCard(),
                child: FlipCard(
                  front: card.front,
                  back: card.back,
                  isFlipped: session.isFlipped,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Boutons de réponse ou "Afficher" / Answer buttons or "Show"
            if (session.isFlipped)
              Column(
                children: [
                  QualityButtons(
                    onAnswer: (quality) {
                      ref
                          .read(reviewSessionProvider.notifier)
                          .answerCard(quality);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Bouton "Je connais déjà" / "I already know" button
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(reviewSessionProvider.notifier)
                          .markAsKnown();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Je connais déjà'),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: () =>
                    ref.read(reviewSessionProvider.notifier).flipCard(),
                icon: const Icon(Icons.flip),
                label: const Text('Afficher la réponse'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Affiche l'écran de fin de session / Show session complete screen
  Widget _buildSessionComplete(
    BuildContext context,
    ReviewSessionState session,
  ) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Session terminée !',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${session.total} carte(s) révisée(s)',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '+${session.pointsEarnedThisSession} points',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppConstants.goodColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home),
                label: const Text('Retour à l\'accueil'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

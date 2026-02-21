import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Widget de chargement centré / Centered loading widget
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// État vide avec icône et message / Empty state with icon and message
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Carte de deck pour l'écran d'accueil / Deck card for home screen
class DeckListTile extends StatelessWidget {
  final String name;
  final int cardCount;
  final int dueCount;
  final int masteryPercent;
  final String? lastSession;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeckListTile({
    super.key,
    required this.name,
    required this.cardCount,
    required this.dueCount,
    required this.masteryPercent,
    this.lastSession,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        onTap: dueCount > 0 ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre et menu
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Stats en ligne
              Row(
                children: [
                  _chip(context, Icons.style, '$cardCount cartes'),
                  const SizedBox(width: 8),
                  _chip(
                    context,
                    Icons.schedule,
                    '$dueCount dues',
                    highlight: dueCount > 0,
                  ),
                  const SizedBox(width: 8),
                  _chip(context, Icons.trending_up, '$masteryPercent%'),
                ],
              ),

              if (lastSession != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Dernière session : $lastSession',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              // Barre de progression maîtrise
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: masteryPercent / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  minHeight: 6,
                ),
              ),

              // Bouton révision si cartes dues
              if (dueCount > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Réviser ($dueCount)'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label, {
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: highlight
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: highlight ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

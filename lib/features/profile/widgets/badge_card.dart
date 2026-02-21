import 'package:flutter/material.dart';

import '../../../models/badge.dart';
import '../../../utils/constants.dart';

/// Widget d'affichage d'un badge (débloqué ou verrouillé).
/// Badge display widget (unlocked or locked).
class BadgeCard extends StatelessWidget {
  final Badge badge;
  final bool unlocked;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: unlocked ? 2 : 0,
      color: unlocked
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              size: 32,
              color: unlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: unlocked
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: unlocked
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

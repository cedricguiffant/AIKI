import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/deck_providers.dart';

/// Dialogue de progression lors de l'import d'un deck.
/// Progress dialog during deck import.
class ImportProgressDialog extends ConsumerWidget {
  const ImportProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deckImportProvider);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          CircularProgressIndicator(value: state.progress > 0 ? state.progress : null),
          const SizedBox(height: 24),
          Text(
            state.statusMessage ?? 'Import en cours...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (state.progress > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 4),
            Text(
              '${(state.progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

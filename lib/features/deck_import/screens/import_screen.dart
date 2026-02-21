import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../providers/deck_providers.dart';
import '../../../providers/settings_providers.dart';
import '../widgets/import_progress_dialog.dart';

/// Écran d'import de deck Anki (.apkg).
/// Anki deck import screen (.apkg).
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(deckImportProvider);
    final geminiKey = ref.watch(geminiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer un deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Format supporté',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sélectionnez un fichier .apkg exporté depuis Anki.\n'
                      'Le deck sera automatiquement importé avec toutes ses cartes.\n\n'
                      'Format attendu :\n'
                      '• Recto : Expression japonaise (kanji/kana)\n'
                      '• Verso : Traduction + lecture',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Clé API Gemini (optionnel)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tri AI (optionnel)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Avec une clé API Gemini, l\'IA trie automatiquement '
                      'les mots que vous connaissez probablement déjà.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: geminiKey ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Clé API Gemini',
                        hintText: 'AIza...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        ref.read(geminiKeyProvider.notifier).setKey(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Bouton d'import / Import button
            FilledButton.icon(
              onPressed: importState.isImporting
                  ? null
                  : () => _pickAndImport(context, ref),
              icon: const Icon(Icons.file_upload),
              label: const Text('Sélectionner un fichier .apkg'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            if (importState.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          importState.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(deckImportProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImport(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      // Note: .apkg n'est pas dans les extensions standards
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    if (!file.path!.endsWith('.apkg')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un fichier .apkg'),
          ),
        );
      }
      return;
    }

    // Afficher le dialogue de progression / Show progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ImportProgressDialog(),
      );
    }

    await ref.read(deckImportProvider.notifier).importApkg(file.path!);

    if (context.mounted) {
      Navigator.of(context).pop(); // Fermer le dialogue
      final state = ref.read(deckImportProvider);
      if (state.error == null) {
        Navigator.of(context).pop(); // Retour à l'accueil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck importé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

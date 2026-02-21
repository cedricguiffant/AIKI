import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/stats_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../utils/extensions.dart';
import '../widgets/badge_card.dart';
import '../widgets/streak_calendar.dart';

/// Écran de profil : stats, badges, streak, paramètres.
/// Profile screen: stats, badges, streak, settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final badgeStatuses = ref.watch(badgeStatusesProvider);
    final themeMode = ref.watch(themeModeProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Stats principales / Main stats ---
          Row(
            children: [
              _buildStatCard(
                context,
                icon: Icons.star,
                value: stats.totalPoints.toFormattedString(),
                label: 'Points',
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                icon: Icons.local_fire_department,
                value: '${stats.currentStreak}',
                label: 'Streak',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                icon: Icons.style,
                value: '${stats.totalCardsReviewed}',
                label: 'Cartes',
                color: theme.colorScheme.primary,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Streak calendar ---
          Text(
            'Historique d\'activité',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreakCalendar(dailyPoints: stats.dailyPoints),

          const SizedBox(height: 24),

          // --- Badges ---
          Text(
            'Badges',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: badgeStatuses.length,
            itemBuilder: (context, index) {
              final item = badgeStatuses[index];
              return BadgeCard(
                badge: item.badge,
                unlocked: item.unlocked,
              );
            },
          ),

          const SizedBox(height: 24),

          // --- Statistiques détaillées / Detailed stats ---
          Text(
            'Statistiques',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _buildStatRow('Sessions totales', '${stats.totalSessions}'),
                const Divider(height: 1),
                _buildStatRow('Meilleur streak', '${stats.bestStreak} jours'),
                const Divider(height: 1),
                _buildStatRow(
                  'Dernière révision',
                  stats.lastReviewDate?.toReadableDate() ?? 'Jamais',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Paramètres / Settings ---
          Text(
            'Paramètres',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode sombre'),
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('Clé API Gemini'),
                  subtitle: Text(
                    ref.watch(geminiKeyProvider) != null
                        ? 'Configurée'
                        : 'Non configurée',
                  ),
                  onTap: () => _showGeminiKeyDialog(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showGeminiKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(geminiKeyProvider) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clé API Gemini'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'AIza...',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(geminiKeyProvider.notifier)
                  .setKey(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}

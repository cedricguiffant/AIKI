import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_stats.dart';
import '../models/badge.dart';
import '../services/database_service.dart';
import '../features/gamification/gamification_service.dart';

/// Notifier pour les stats utilisateur / User stats notifier
class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(DatabaseService.getUserStats());

  void refresh() {
    state = DatabaseService.getUserStats();
  }
}

final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});

/// Provider des statuts de badges / Badge statuses provider
final badgeStatusesProvider =
    Provider<List<({AppBadge badge, bool unlocked})>>((ref) {
  final stats = ref.watch(userStatsProvider);
  return GamificationService.getBadgeStatuses(stats);
});

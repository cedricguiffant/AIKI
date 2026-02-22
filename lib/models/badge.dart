import 'package:flutter/material.dart';

/// Définition d'un badge de gamification.
/// Gamification badge definition.
class AppBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int requiredPoints;
  final int? requiredStreak;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.requiredPoints = 0,
    this.requiredStreak,
  });

  /// Vérifie si le badge est débloqué / Check if badge is unlocked
  bool isUnlocked(int totalPoints, int currentStreak) {
    if (requiredStreak != null) {
      return currentStreak >= requiredStreak!;
    }
    return totalPoints >= requiredPoints;
  }
}

/// Liste de tous les badges disponibles / All available badges
class AppBadges {
  static const List<AppBadge> all = [
    // Badges par points / Points-based badges
    AppBadge(
      id: 'debutant',
      name: 'Débutant',
      description: '500 points accumulés',
      icon: Icons.emoji_events_outlined,
      requiredPoints: 500,
    ),
    AppBadge(
      id: 'samourai',
      name: 'Samouraï',
      description: '2000 points accumulés',
      icon: Icons.shield_outlined,
      requiredPoints: 2000,
    ),
    AppBadge(
      id: 'sensei',
      name: 'Sensei',
      description: '5000 points accumulés',
      icon: Icons.school_outlined,
      requiredPoints: 5000,
    ),
    // Badges par streak / Streak-based badges
    AppBadge(
      id: 'streak_7',
      name: 'Semaine parfaite',
      description: '7 jours consécutifs',
      icon: Icons.local_fire_department,
      requiredStreak: 7,
    ),
    AppBadge(
      id: 'streak_30',
      name: 'Mois de feu',
      description: '30 jours consécutifs',
      icon: Icons.whatshot,
      requiredStreak: 30,
    ),
    AppBadge(
      id: 'streak_100',
      name: 'Légende',
      description: '100 jours consécutifs',
      icon: Icons.military_tech,
      requiredStreak: 100,
    ),
  ];

  /// Retourne les badges nouvellement débloqués / Get newly unlocked badges
  static List<AppBadge> getNewlyUnlocked(
    int totalPoints,
    int currentStreak,
    List<String> alreadyEarned,
  ) {
    return all
        .where((b) =>
            b.isUnlocked(totalPoints, currentStreak) &&
            !alreadyEarned.contains(b.id))
        .toList();
  }
}

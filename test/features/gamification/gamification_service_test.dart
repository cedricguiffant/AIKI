import 'package:flutter_test/flutter_test.dart';
import 'package:kana_srs/features/gamification/gamification_service.dart';
import 'package:kana_srs/features/srs/srs_engine.dart';
import 'package:kana_srs/models/user_stats.dart';
import 'package:kana_srs/models/badge.dart';

void main() {
  group('GamificationService', () {
    late UserStats freshStats;

    setUp(() {
      freshStats = UserStats();
    });

    group('processReview', () {
      test('Ajoute les points corrects pour chaque qualité', () {
        var stats = UserStats();
        stats = GamificationService.processReview(
          stats,
          ReviewQuality.again,
        );
        expect(stats.totalPoints, 5);

        stats = UserStats();
        stats = GamificationService.processReview(
          stats,
          ReviewQuality.hard,
        );
        expect(stats.totalPoints, 10);

        stats = UserStats();
        stats = GamificationService.processReview(
          stats,
          ReviewQuality.good,
        );
        expect(stats.totalPoints, 15);

        stats = UserStats();
        stats = GamificationService.processReview(
          stats,
          ReviewQuality.easy,
        );
        expect(stats.totalPoints, 25);
      });

      test('Incrémente le compteur de cartes révisées', () {
        final stats = GamificationService.processReview(
          freshStats,
          ReviewQuality.good,
        );
        expect(stats.totalCardsReviewed, 1);
      });

      test('Démarre le streak à 1 pour la première révision', () {
        final stats = GamificationService.processReview(
          freshStats,
          ReviewQuality.good,
          isFirstReviewToday: true,
        );
        expect(stats.currentStreak, 1);
      });

      test('Ajoute bonus streak pour les jours consécutifs', () {
        // Simuler un streak existant avec révision hier
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final existingStats = UserStats(
          currentStreak: 3,
          lastReviewDate: yesterday,
        );

        final updated = GamificationService.processReview(
          existingStats,
          ReviewQuality.good,
          isFirstReviewToday: true,
        );

        // 15 (good) + 50 (streak bonus) = 65
        expect(updated.totalPoints, 65);
        expect(updated.currentStreak, 4);
      });
    });

    group('endSession', () {
      test('Incrémente le compteur de sessions', () {
        expect(freshStats.totalSessions, 0);
        final updated = GamificationService.endSession(freshStats);
        expect(updated.totalSessions, 1);
      });
    });

    group('calculateMasteryPercent', () {
      test('Retourne 0 pour un deck vide', () {
        expect(
          GamificationService.calculateMasteryPercent(0, 0, 0),
          0,
        );
      });

      test('100% quand toutes les cartes sont matures', () {
        expect(
          GamificationService.calculateMasteryPercent(10, 10, 0),
          100,
        );
      });

      test('Cartes connues comptent pour 50%', () {
        // 5 known * 0.5 / 10 = 25%
        expect(
          GamificationService.calculateMasteryPercent(10, 0, 5),
          25,
        );
      });

      test('Mix mature + known', () {
        // (3 * 1.0 + 4 * 0.5) / 10 = 5 / 10 = 50%
        expect(
          GamificationService.calculateMasteryPercent(10, 3, 4),
          50,
        );
      });
    });
  });

  group('UserStats', () {
    group('updateStreak', () {
      test('Premier jour : streak = 1', () {
        final stats = UserStats();
        stats.updateStreak();
        expect(stats.currentStreak, 1);
      });

      test('Jour consécutif : streak += 1', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = UserStats(currentStreak: 5, lastReviewDate: yesterday);
        stats.updateStreak();
        expect(stats.currentStreak, 6);
      });

      test('Même jour : streak inchangé', () {
        final today = DateTime.now();
        final stats = UserStats(currentStreak: 5, lastReviewDate: today);
        stats.updateStreak();
        expect(stats.currentStreak, 5);
      });

      test('Jour manqué : streak reset à 1', () {
        final twoDaysAgo =
            DateTime.now().subtract(const Duration(days: 2));
        final stats =
            UserStats(currentStreak: 10, lastReviewDate: twoDaysAgo);
        stats.updateStreak();
        expect(stats.currentStreak, 1);
      });

      test('Met à jour bestStreak si dépassé', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = UserStats(
          currentStreak: 5,
          bestStreak: 5,
          lastReviewDate: yesterday,
        );
        stats.updateStreak();
        expect(stats.currentStreak, 6);
        expect(stats.bestStreak, 6);
      });
    });

    group('isStreakAtRisk', () {
      test('Pas de streak → pas de risque', () {
        final stats = UserStats(currentStreak: 0);
        expect(stats.isStreakAtRisk, false);
      });

      test('Révisé aujourd\'hui → pas de risque', () {
        final stats = UserStats(
          currentStreak: 5,
          lastReviewDate: DateTime.now(),
        );
        expect(stats.isStreakAtRisk, false);
      });

      test('Pas révisé aujourd\'hui avec streak actif → risque', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = UserStats(
          currentStreak: 5,
          lastReviewDate: yesterday,
        );
        expect(stats.isStreakAtRisk, true);
      });
    });

    group('addPoints', () {
      test('Ajoute des points au total et à l\'historique quotidien', () {
        final stats = UserStats();
        stats.addPoints(100);
        expect(stats.totalPoints, 100);
        expect(stats.dailyPoints.isNotEmpty, true);

        stats.addPoints(50);
        expect(stats.totalPoints, 150);
      });
    });
  });

  group('ReviewCard', () {
    test('isDue retourne true si la date est passée', () {
      final card = _makeCard(
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(card.isDue, true);
    });

    test('isDue retourne false si la date est future', () {
      final card = _makeCard(
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(card.isDue, false);
    });

    test('isYoung si intervalle < 21', () {
      final card = _makeCard(intervalDays: 10);
      expect(card.isYoung, true);
      expect(card.isMature, false);
    });

    test('isMature si intervalle >= 21', () {
      final card = _makeCard(intervalDays: 21);
      expect(card.isYoung, false);
      expect(card.isMature, true);
    });
  });

  group('Badge', () {
    test('Badges de points se débloquent au bon seuil', () {
      final debutant = AppBadges.all.firstWhere((b) => b.id == 'debutant');
      expect(debutant.isUnlocked(499, 0), false);
      expect(debutant.isUnlocked(500, 0), true);
    });

    test('Badges de streak se débloquent au bon seuil', () {
      final streak7 = AppBadges.all.firstWhere((b) => b.id == 'streak_7');
      expect(streak7.isUnlocked(0, 6), false);
      expect(streak7.isUnlocked(0, 7), true);
    });

    test('getNewlyUnlocked exclut les badges déjà obtenus', () {
      final newBadges = AppBadges.getNewlyUnlocked(500, 7, ['debutant']);
      expect(newBadges.any((b) => b.id == 'debutant'), false);
      expect(newBadges.any((b) => b.id == 'streak_7'), true);
    });
  });
}

ReviewCard _makeCard({
  DateTime? dueDate,
  int intervalDays = 0,
}) {
  return ReviewCard(
    id: 'test',
    deckId: 'deck',
    front: 'テスト',
    back: 'Test',
    intervalDays: intervalDays,
    dueDate: dueDate ?? DateTime.now(),
  );
}

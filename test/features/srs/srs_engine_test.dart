import 'package:flutter_test/flutter_test.dart';
import 'package:kana_srs/features/srs/srs_engine.dart';
import 'package:kana_srs/models/review_card.dart';

void main() {
  group('SrsEngine', () {
    late ReviewCard newCard;

    setUp(() {
      newCard = ReviewCard(
        id: 'test_1',
        deckId: 'deck_1',
        front: '食べる',
        back: 'Manger (taberu)',
        easeFactor: 2.5,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
      );
    });

    group('processAnswer - nouvelle carte', () {
      test('Again : remet à 1 jour, baisse ease, incrémente lapses', () {
        final result = SrsEngine.processAnswer(newCard, ReviewQuality.again);

        expect(result.intervalDays, 1);
        expect(result.reps, 0);
        expect(result.lapses, 1);
        expect(result.easeFactor, closeTo(2.3, 0.01));
        expect(result.lastReview, isNotNull);
      });

      test('Hard : 1 jour première rep, baisse ease', () {
        final result = SrsEngine.processAnswer(newCard, ReviewQuality.hard);

        expect(result.intervalDays, 1);
        expect(result.reps, 1);
        expect(result.lapses, 0);
        expect(result.easeFactor, closeTo(2.35, 0.01));
      });

      test('Good : 1 jour première rep, ease inchangé', () {
        final result = SrsEngine.processAnswer(newCard, ReviewQuality.good);

        expect(result.intervalDays, 1);
        expect(result.reps, 1);
        expect(result.lapses, 0);
        expect(result.easeFactor, 2.5);
      });

      test('Easy : 3 jours première rep, augmente ease', () {
        final result = SrsEngine.processAnswer(newCard, ReviewQuality.easy);

        expect(result.intervalDays, 3);
        expect(result.reps, 1);
        expect(result.lapses, 0);
        expect(result.easeFactor, closeTo(2.65, 0.01));
      });
    });

    group('processAnswer - deuxième répétition', () {
      late ReviewCard secondRepCard;

      setUp(() {
        secondRepCard = newCard.copyWith(
          reps: 1,
          intervalDays: 1,
          easeFactor: 2.5,
        );
      });

      test('Good deuxième rep : intervalle = 6 jours', () {
        final result =
            SrsEngine.processAnswer(secondRepCard, ReviewQuality.good);

        expect(result.intervalDays, 6);
        expect(result.reps, 2);
      });

      test('Hard deuxième rep : intervalle = 4 jours', () {
        final result =
            SrsEngine.processAnswer(secondRepCard, ReviewQuality.hard);

        expect(result.intervalDays, 4);
        expect(result.reps, 2);
      });

      test('Easy deuxième rep : intervalle = 8 jours', () {
        final result =
            SrsEngine.processAnswer(secondRepCard, ReviewQuality.easy);

        expect(result.intervalDays, 8);
        expect(result.reps, 2);
      });
    });

    group('processAnswer - carte mature', () {
      test('Good sur carte mature : intervalle *= ease', () {
        final matureCard = newCard.copyWith(
          reps: 5,
          intervalDays: 30,
          easeFactor: 2.5,
        );

        final result =
            SrsEngine.processAnswer(matureCard, ReviewQuality.good);

        // 30 * 2.5 = 75
        expect(result.intervalDays, 75);
        expect(result.reps, 6);
      });

      test('Again sur carte mature : reset interval à 1, incrémente lapses',
          () {
        final matureCard = newCard.copyWith(
          reps: 5,
          intervalDays: 30,
          easeFactor: 2.5,
        );

        final result =
            SrsEngine.processAnswer(matureCard, ReviewQuality.again);

        expect(result.intervalDays, 1);
        expect(result.reps, 0);
        expect(result.lapses, 1);
      });

      test('Easy sur carte mature : intervalle *= ease * 1.3', () {
        final matureCard = newCard.copyWith(
          reps: 5,
          intervalDays: 30,
          easeFactor: 2.5,
        );

        final result =
            SrsEngine.processAnswer(matureCard, ReviewQuality.easy);

        // 30 * (2.5 + 0.15) * 1.3 = 30 * 2.65 * 1.3 = 103.35 ≈ 103
        expect(result.intervalDays, 103);
        expect(result.easeFactor, closeTo(2.65, 0.01));
      });
    });

    group('processAnswer - ease factor minimum', () {
      test('Ease ne descend pas en dessous de 1.3', () {
        final lowEaseCard = newCard.copyWith(easeFactor: 1.35);

        final result =
            SrsEngine.processAnswer(lowEaseCard, ReviewQuality.again);

        expect(result.easeFactor, greaterThanOrEqualTo(1.3));
      });
    });

    group('processAnswer - intervalle maximum', () {
      test('Intervalle ne dépasse pas 3650 jours', () {
        final hugeCard = newCard.copyWith(
          reps: 20,
          intervalDays: 3000,
          easeFactor: 3.0,
        );

        final result =
            SrsEngine.processAnswer(hugeCard, ReviewQuality.easy);

        expect(result.intervalDays, lessThanOrEqualTo(3650));
      });
    });

    group('sortDueCards', () {
      test('Trie par priorité : lapses > young > mature', () {
        final now = DateTime.now().subtract(const Duration(hours: 1));
        final cards = [
          newCard.copyWith(
            id: 'mature',
            intervalDays: 30,
            lapses: 0,
            dueDate: now,
          ),
          newCard.copyWith(
            id: 'lapsed',
            intervalDays: 5,
            lapses: 2,
            dueDate: now,
          ),
          newCard.copyWith(
            id: 'young',
            intervalDays: 3,
            lapses: 0,
            dueDate: now,
          ),
        ];

        final sorted = SrsEngine.sortDueCards(cards);

        expect(sorted[0].id, 'lapsed'); // Lapses d'abord
        expect(sorted[1].id, 'young'); // Puis young
        expect(sorted[2].id, 'mature'); // Puis mature
      });

      test('Exclut les cartes non dues', () {
        final futureCard = newCard.copyWith(
          id: 'future',
          dueDate: DateTime.now().add(const Duration(days: 5)),
        );
        final dueCard = newCard.copyWith(
          id: 'due',
          dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final sorted = SrsEngine.sortDueCards([futureCard, dueCard]);

        expect(sorted.length, 1);
        expect(sorted[0].id, 'due');
      });
    });

    group('pointsForQuality', () {
      test('Retourne les bons points par qualité', () {
        expect(SrsEngine.pointsForQuality(ReviewQuality.again), 5);
        expect(SrsEngine.pointsForQuality(ReviewQuality.hard), 10);
        expect(SrsEngine.pointsForQuality(ReviewQuality.good), 15);
        expect(SrsEngine.pointsForQuality(ReviewQuality.easy), 25);
      });
    });
  });
}

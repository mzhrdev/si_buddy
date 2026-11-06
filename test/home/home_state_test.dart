import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/home/domain/home_models.dart';
import 'package:si_buddy/features/study/domain/study_models.dart';

StudyDeck _deck() => StudyDeck(
  id: 1,
  documentId: 1,
  title: 'Cells',
  materialType: GenerationMaterialType.flashcards,
  totalItems: 10,
  createdAt: DateTime(2026, 11, 6),
  updatedAt: DateTime(2026, 11, 6),
);

IncompleteActivity _incomplete() => IncompleteActivity(
  deck: _deck(),
  kind: IncompleteActivityKind.notStarted,
  currentIndex: 0,
  totalItems: 10,
);

void main() {
  group('deriveHomeState', () {
    test('no model wins over everything else (state A)', () {
      expect(
        deriveHomeState(
          modelReady: false,
          documentCount: 3,
          deckCount: 2,
          incomplete: _incomplete(),
          hasCompletedActivity: true,
        ),
        HomeState.noModel,
      );
    });

    test('model but no documents (state B)', () {
      expect(
        deriveHomeState(
          modelReady: true,
          documentCount: 0,
          deckCount: 0,
          incomplete: null,
          hasCompletedActivity: false,
        ),
        HomeState.noDocuments,
      );
    });

    test('documents but no study sets (state C)', () {
      expect(
        deriveHomeState(
          modelReady: true,
          documentCount: 2,
          deckCount: 0,
          incomplete: null,
          hasCompletedActivity: false,
        ),
        HomeState.noStudySets,
      );
    });

    test('unfinished work (state D/F)', () {
      expect(
        deriveHomeState(
          modelReady: true,
          documentCount: 2,
          deckCount: 1,
          incomplete: _incomplete(),
          hasCompletedActivity: true,
        ),
        HomeState.active,
      );
    });

    test('only completed activity (state E)', () {
      expect(
        deriveHomeState(
          modelReady: true,
          documentCount: 2,
          deckCount: 1,
          incomplete: null,
          hasCompletedActivity: true,
        ),
        HomeState.completedOnly,
      );
    });

    test(
      'decks exist but nothing unfinished or completed falls back to history',
      () {
        expect(
          deriveHomeState(
            modelReady: true,
            documentCount: 2,
            deckCount: 1,
            incomplete: null,
            hasCompletedActivity: false,
          ),
          HomeState.completedOnly,
        );
      },
    );
  });

  group('PickUpItem', () {
    test('flashcard progress reads reviewed of total', () {
      const item = PickUpItem(
        deckId: 1,
        title: 'Cells',
        isQuiz: false,
        currentIndex: 3,
        totalItems: 10,
      );
      expect(item.progressText, '3 of 10 reviewed');
      expect(item.fraction, 0.3);
      expect(item.kindLabel, 'Flashcards');
    });

    test('quiz progress reads the next question number', () {
      const item = PickUpItem(
        deckId: 2,
        title: 'Cells quiz',
        isQuiz: true,
        currentIndex: 2,
        totalItems: 10,
      );
      expect(item.progressText, 'Question 3 of 10');
      expect(item.kindLabel, 'Quiz');
    });
  });
}

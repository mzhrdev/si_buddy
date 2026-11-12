import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';
import 'package:si_buddy/app/router.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final name in [
    'Inter-400',
    'Inter-500',
    'Inter-600',
    'Inter-700',
    'Inter-800',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$name.ttf'));
  }
  await loader.load();
}

/// A completed quiz job: three MCQ questions, no source document
/// (the screen shows the design's fallback card without one).
class _CompletedQuizJobNotifier extends GenerationJobNotifier {
  @override
  GenerationJobState build() {
    return GenerationJobState(
      status: GenerationJobStatus.completed,
      config: const GenerationConfig(
        materialType: GenerationMaterialType.mcqs,
        count: 3,
      ),
      result: const GenerationResult(
        documentId: 1,
        questions: [
          GeneratedQuizQuestion(
            prompt: 'First question?',
            type: QuizQuestionType.mcq,
            options: ['A1', 'B1', 'C1', 'D1'],
            correctIndex: 0,
          ),
          GeneratedQuizQuestion(
            prompt: 'Second question?',
            type: QuizQuestionType.mcq,
            options: ['A2', 'B2', 'C2', 'D2'],
            correctIndex: 1,
          ),
          GeneratedQuizQuestion(
            prompt: 'Third question?',
            type: QuizQuestionType.mcq,
            options: ['A3', 'B3', 'C3', 'D3'],
            correctIndex: 2,
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(_loadInter);

  testWidgets('MCQ quiz walks through its questions, then submits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(AppRoutes.mcq);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          generationJobProvider.overrideWith(_CompletedQuizJobNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Question 1 of 3, with its own options.
    expect(find.text('First question?'), findsOneWidget);
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('A2'), findsNothing);

    // Next moves within the same quiz — not to another type's screen.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Second question?'), findsOneWidget);
    expect(find.text('Question 2 of 3'), findsOneWidget);

    // Answering is kept when moving between questions.
    await tester.tap(find.text('B2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Third question?'), findsOneWidget);
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Second question?'), findsOneWidget);
    expect(find.text('1 / 3 answered'), findsOneWidget);

    // Next on the last question opens the submit check.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('unanswered question'), findsOneWidget);
  });
}

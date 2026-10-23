import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/generation_repository_impl.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';

void main() {
  group('GenerationConfig', () {
    test('defaults match the generation setup design', () {
      const config = GenerationConfig();

      expect(config.materialType, GenerationMaterialType.flashcards);
      expect(config.count, 20);
      expect(config.difficulty, GenerationDifficulty.medium);
      expect(config.topic, 'Cell structures');
      expect(config.language, 'English');
      expect(config.includeExplanations, isTrue);
      expect(config.documentId, isNull);
    });

    test('enum labels are the setup screen chip strings', () {
      expect(GenerationMaterialType.values.map((t) => t.label), [
        'Flashcards',
        'MCQs',
        'True/false',
        'Short answers',
        'Summaries',
      ]);
      expect(GenerationDifficulty.values.map((d) => d.label), [
        'Easy',
        'Medium',
        'Hard',
      ]);
    });

    test('copyWith changes only the given fields', () {
      const config = GenerationConfig();

      final changed = config.copyWith(
        materialType: GenerationMaterialType.mcqs,
        count: 12,
        includeExplanations: false,
      );

      expect(changed.materialType, GenerationMaterialType.mcqs);
      expect(changed.count, 12);
      expect(changed.includeExplanations, isFalse);
      // Untouched fields keep the design defaults.
      expect(changed.difficulty, config.difficulty);
      expect(changed.topic, config.topic);
      expect(changed.language, config.language);
      expect(changed.documentId, config.documentId);
    });

    test('value equality and hashCode cover every field', () {
      const a = GenerationConfig();
      const b = GenerationConfig();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.copyWith(count: 21), isNot(equals(a)));
      expect(
        a.copyWith(materialType: GenerationMaterialType.summaries),
        isNot(equals(a)),
      );
      expect(a.copyWith(documentId: 7), isNot(equals(a)));
    });
  });

  group('GenerationConfigNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GenerationConfig read() => container.read(generationConfigProvider);

    GenerationConfigNotifier notifier() =>
        container.read(generationConfigProvider.notifier);

    test('starts at the design defaults', () {
      expect(read(), equals(const GenerationConfig()));
    });

    test('material type chips update the material type', () {
      notifier().setMaterialType(GenerationMaterialType.trueFalse);
      expect(read().materialType, GenerationMaterialType.trueFalse);

      notifier().setMaterialType(GenerationMaterialType.flashcards);
      expect(read().materialType, GenerationMaterialType.flashcards);
    });

    test('difficulty chips update the difficulty', () {
      notifier().setDifficulty(GenerationDifficulty.hard);
      expect(read().difficulty, GenerationDifficulty.hard);
    });

    test('stepper increments and decrements the count', () {
      notifier().incrementCount();
      expect(read().count, 21);

      notifier().decrementCount();
      notifier().decrementCount();
      expect(read().count, 19);
    });

    test('count clamps at the designed lower bound of 1', () {
      notifier().setCount(1);
      notifier().decrementCount();
      expect(read().count, 1);

      notifier().setCount(0);
      expect(read().count, 1);

      notifier().setCount(-5);
      expect(read().count, 1);
    });

    test('count has no upper clamp on this screen (unlike quiz setup)', () {
      notifier().setCount(50);
      notifier().incrementCount();
      expect(read().count, 51);
    });

    test('explanations toggle updates the flag', () {
      notifier().setIncludeExplanations(false);
      expect(read().includeExplanations, isFalse);

      notifier().setIncludeExplanations(true);
      expect(read().includeExplanations, isTrue);
    });

    test('topic and language fields update', () {
      notifier().setTopic('Membranes');
      notifier().setLanguage('Urdu');

      expect(read().topic, 'Membranes');
      expect(read().language, 'Urdu');
    });

    test('document id binds the source document', () {
      notifier().setDocumentId(42);
      expect(read().documentId, 42);
    });

    test('changing one control leaves the others untouched', () {
      notifier().setDifficulty(GenerationDifficulty.easy);

      final config = read();
      expect(config.materialType, GenerationMaterialType.flashcards);
      expect(config.count, 20);
      expect(config.includeExplanations, isTrue);
    });
  });

  group('generationRepositoryProvider', () {
    test('is bound to the real implementation over the engine seam', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // The runtime integration binds the flutter_edge_ai-backed
      // implementation; constructing it touches no platform channel.
      expect(
        container.read(generationRepositoryProvider),
        isA<GenerationRepositoryImpl>(),
      );
    });

    test('boundGenerationRepositoryProvider returns the implementation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(boundGenerationRepositoryProvider), isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/generation_prompts.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/documents/domain/document_models.dart';

ExtractedDocument sourceWith(String text, {List<String>? sections}) {
  final now = DateTime(2026, 1, 1);
  return ExtractedDocument(
    document: Document(
      id: 7,
      title: 'Cell Biology - Chapter 4',
      originalFileName: 'Cell Biology - Chapter 4.pdf',
      format: DocumentFormat.pdf,
      sizeBytes: 2400000,
      pageCount: 12,
      folderId: null,
      createdAt: now,
      updatedAt: now,
      storedPath: '/tmp/doc.pdf',
    ),
    fullText: text,
    sections: sections ?? [text],
    charCount: text.length,
  );
}

void main() {
  const cellText =
      'The mitochondria is the powerhouse of the cell. '
      'It produces ATP through cellular respiration.';

  group('buildGenerationPrompt', () {
    test('embeds config and source text for every material type', () {
      for (final type in GenerationMaterialType.values) {
        final prompt = buildGenerationPrompt(
          source: sourceWith(cellText),
          config: GenerationConfig(materialType: type, count: 3),
        );
        // No topic is set, so the prompt refers to the notes rather
        // than the design's sample topic.
        expect(prompt, contains('the notes'), reason: '$type topic');
        expect(prompt, contains('Medium'), reason: '$type difficulty');
        expect(prompt, contains('English'), reason: '$type language');
        expect(prompt, contains('mitochondria'), reason: '$type source');
      }
    });

    test('embeds a set topic instead of the notes fallback', () {
      final prompt = buildGenerationPrompt(
        source: sourceWith(cellText),
        config: const GenerationConfig(topic: 'Photosynthesis', count: 3),
      );
      expect(prompt, contains('Photosynthesis'));
    });

    test('shows two example blocks and tells the model not to stop after the first', () {
      // A 1B model shown a single example block tends to emit one
      // item and stop, so a 10-question quiz came back with a single
      // question. Every task now shows the repeat pattern.
      for (final type in [
        GenerationMaterialType.flashcards,
        GenerationMaterialType.mcqs,
        GenerationMaterialType.trueFalse,
        GenerationMaterialType.shortAnswers,
      ]) {
        final prompt = buildGenerationPrompt(
          source: sourceWith(cellText),
          config: GenerationConfig(materialType: type, count: 10),
        );
        expect(prompt, contains('do not stop after the first one'), reason: '$type');
        expect(prompt, contains('Create all 10'), reason: '$type');
      }
      final mcq = buildGenerationPrompt(
        source: sourceWith(cellText),
        config: const GenerationConfig(materialType: GenerationMaterialType.mcqs, count: 10),
      );
      expect(mcq, contains('2. <another question>'));
      final cards = buildGenerationPrompt(
        source: sourceWith(cellText),
        config: const GenerationConfig(materialType: GenerationMaterialType.flashcards, count: 10),
      );
      expect(cards, contains('Q: <another question>'));
    });

    test('requests the line format each parser consumes', () {
      String promptFor(GenerationMaterialType type) => buildGenerationPrompt(
        source: sourceWith(cellText),
        config: GenerationConfig(materialType: type, count: 2),
      );

      expect(promptFor(GenerationMaterialType.flashcards), contains('Q:'));
      expect(promptFor(GenerationMaterialType.flashcards), contains('A:'));
      expect(promptFor(GenerationMaterialType.mcqs), contains('ANSWER:'));
      expect(promptFor(GenerationMaterialType.mcqs), contains('A)'));
      expect(
        promptFor(GenerationMaterialType.trueFalse),
        contains('ANSWER: <True or False>'),
      );
      expect(
        promptFor(GenerationMaterialType.shortAnswers),
        contains('ANSWER:'),
      );
      expect(promptFor(GenerationMaterialType.summaries), contains('##'));
    });

    test('asks for explanations only when the config includes them', () {
      final withE = buildGenerationPrompt(
        source: sourceWith(cellText),
        config: const GenerationConfig(includeExplanations: true),
      );
      final withoutE = buildGenerationPrompt(
        source: sourceWith(cellText),
        config: const GenerationConfig(includeExplanations: false),
      );
      expect(withE, contains('E: <one short sentence explaining the answer>'));
      expect(withoutE, isNot(contains('E: <one short sentence')));
    });

    test('respects the character budget for long sources', () {
      final longText = 'x' * 20000;
      final prompt = buildGenerationPrompt(
        source: sourceWith(longText),
        config: const GenerationConfig(),
      );
      // Header + sampled text: the sample never exceeds the budget.
      expect(prompt.length, lessThan(sourceTextBudgetChars + 1500));
      expect(
        sampleSourceText(sourceWith(longText)).length,
        sourceTextBudgetChars,
      );
    });

    test('samples every section proportionally instead of truncating', () {
      final sections = ['a' * 4000, 'b' * 4000, 'c' * 4000];
      // fullText is the sections joined, as extraction produces it.
      final sampled = sampleSourceText(
        sourceWith(sections.join('\n\n'), sections: sections),
      );
      expect(sampled, contains('aaa'));
      expect(sampled, contains('bbb'));
      expect(sampled, contains('ccc'));
      expect(sampled.length, lessThanOrEqualTo(sourceTextBudgetChars + 10));
    });

    test('short sources pass through whole', () {
      expect(sampleSourceText(sourceWith(cellText)), cellText);
    });
  });
}

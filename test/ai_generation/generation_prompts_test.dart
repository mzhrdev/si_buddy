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
        expect(prompt, contains('Cell structures'), reason: '$type topic');
        expect(prompt, contains('Medium'), reason: '$type difficulty');
        expect(prompt, contains('English'), reason: '$type language');
        expect(prompt, contains('mitochondria'), reason: '$type source');
      }
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

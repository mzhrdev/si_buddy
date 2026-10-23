import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/generation_output_parser.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';

void main() {
  group('parseFlashcards', () {
    const output = '''
Here are your flashcards:

Q: What organelle produces ATP?
A: The mitochondria.
E: It runs cellular respiration.

Q: What does the nucleus store?
A: DNA.
''';

    test('parses Q/A/E blocks', () {
      final cards = parseFlashcards(
        output,
        maxCount: 20,
        includeExplanations: true,
      );
      expect(cards, hasLength(2));
      expect(cards[0].front, 'What organelle produces ATP?');
      expect(cards[0].back, 'The mitochondria.');
      expect(cards[0].explanation, 'It runs cellular respiration.');
      expect(cards[1].front, 'What does the nucleus store?');
      expect(cards[1].explanation, isNull);
    });

    test('drops explanations when not requested', () {
      final cards = parseFlashcards(
        output,
        maxCount: 20,
        includeExplanations: false,
      );
      expect(cards[0].explanation, isNull);
    });

    test('joins multi-line answers and strips markdown emphasis', () {
      final cards = parseFlashcards(
        'Q: **What is ATP?**\nA: Adenosine triphosphate,\nthe cell\u2019s energy currency.',
        maxCount: 5,
        includeExplanations: false,
      );
      expect(cards, hasLength(1));
      expect(cards.single.front, 'What is ATP?');
      expect(cards.single.back, contains('energy currency'));
    });

    test('skips malformed entries (question without an answer)', () {
      final cards = parseFlashcards(
        'Q: A question with no answer.\n\nQ: Good?\nA: Yes.',
        maxCount: 5,
        includeExplanations: false,
      );
      expect(cards, hasLength(1));
      expect(cards.single.front, 'Good?');
    });

    test('caps at maxCount', () {
      final many = List.generate(6, (i) => 'Q: Q$i?\nA: A$i.').join('\n\n');
      expect(
        parseFlashcards(many, maxCount: 3, includeExplanations: false),
        hasLength(3),
      );
    });

    test('garbage parses to empty', () {
      expect(
        parseFlashcards(
          'the model rambled without any structure at all',
          maxCount: 5,
          includeExplanations: false,
        ),
        isEmpty,
      );
      expect(
        parseFlashcards('', maxCount: 5, includeExplanations: false),
        isEmpty,
      );
    });
  });

  group('parseMcqs', () {
    const output = '''
1. Which organelle produces ATP?
A) Nucleus
B) Mitochondria
C) Ribosome
D) Golgi body
ANSWER: B

2. What does DNA store?
A) Energy
B) Genetic information
ANSWER: B
''';

    test('parses questions, options and the correct letter', () {
      final questions = parseMcqs(output, maxCount: 10, includeExplanations: false);
      expect(questions, hasLength(2));
      expect(questions[0].type, QuizQuestionType.mcq);
      expect(questions[0].prompt, 'Which organelle produces ATP?');
      expect(questions[0].options, hasLength(4));
      expect(questions[0].correctIndex, 1);
      expect(questions[1].options, ['Energy', 'Genetic information']);
      expect(questions[1].correctIndex, 1);
    });

    test('skips entries without a usable correct answer', () {
      final questions = parseMcqs(
        includeExplanations: false,
        '1. Broken?\nA) One\nB) Two\nANSWER: E\n\n2. Fine?\nA) One\nB) Two\nANSWER: A',
        maxCount: 10,
      );
      expect(questions, hasLength(1));
      expect(questions.single.prompt, 'Fine?');
    });

    test('skips entries with fewer than two options', () {
      final questions = parseMcqs(
        '1. Thin?\nA) Only one\nANSWER: A',
        maxCount: 10,
        includeExplanations: false,
      );
      expect(questions, isEmpty);
    });

    test('garbage parses to empty', () {
      expect(parseMcqs('no structure here', maxCount: 5, includeExplanations: false), isEmpty);
    });
  });

  group('parseTrueFalse', () {
    test('parses statements with True/False answers', () {
      final questions = parseTrueFalse(
        '1. The mitochondria produces ATP.\nANSWER: True\n\n'
        '2. DNA is stored in the ribosome.\nANSWER: False',
        maxCount: 10,
        includeExplanations: false,
      );
      expect(questions, hasLength(2));
      expect(questions[0].type, QuizQuestionType.trueFalse);
      expect(questions[0].options, ['True', 'False']);
      expect(questions[0].correctIndex, 0);
      expect(questions[1].correctIndex, 1);
    });

    test('skips statements without a True/False answer', () {
      final questions = parseTrueFalse(
        '1. Something.\nANSWER: Maybe',
        maxCount: 10,
        includeExplanations: false,
      );
      expect(questions, isEmpty);
    });
  });

  group('parseShortAnswers', () {
    test('parses questions with expected answers', () {
      final questions = parseShortAnswers(
        '1. Which organelle produces ATP?\nANSWER: The mitochondria\n\n'
        '2. What does DNA store?\nANSWER: Genetic information',
        maxCount: 10,
        includeExplanations: false,
      );
      expect(questions, hasLength(2));
      expect(questions[0].type, QuizQuestionType.shortAnswer);
      expect(questions[0].expectedAnswer, 'The mitochondria');
      expect(questions[0].options, isEmpty);
      expect(questions[0].correctIndex, isNull);
    });

    test('skips questions without an answer', () {
      expect(
        parseShortAnswers('1. Unanswered?', maxCount: 10, includeExplanations: false),
        isEmpty,
      );
    });
  });

  group('parseSummary', () {
    test('headed sections become cards, front = heading', () {
      final cards = parseSummary(
        '## Photosynthesis\nPlants convert sunlight into energy.\n\n'
        '## Respiration\nCells release energy from glucose.',
        maxCount: 10,
        topic: 'Cell processes',
      );
      expect(cards, hasLength(2));
      expect(cards[0].front, 'Photosynthesis');
      expect(cards[0].back, contains('sunlight'));
      expect(cards[1].front, 'Respiration');
    });

    test('heading-free prose becomes one card titled by the topic', () {
      final cards = parseSummary(
        'A single block of summary prose.',
        maxCount: 10,
        topic: 'Cell structures',
      );
      expect(cards, hasLength(1));
      expect(cards.single.front, 'Cell structures');
      expect(cards.single.back, 'A single block of summary prose.');
    });

    test('empty output parses to empty', () {
      expect(parseSummary('   ', maxCount: 10, topic: 'T'), isEmpty);
    });
  });
}

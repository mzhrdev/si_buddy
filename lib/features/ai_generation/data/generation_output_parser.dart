// Parsers for the model's replies: they turn the line-based formats
// requested by generation_prompts.dart into domain items.
//
// Tolerance is the contract: small models drift from the requested
// format, so every parser skips malformed entries instead of
// failing, caps the result at the requested count, and returns an
// empty list for garbage rather than throwing. An empty parse is a
// generation failure the repository reports — a half-parsed one is
// still useful study material.

import '../domain/generation_models.dart';

/// Cleans one raw reply line for marker detection: trims space and
/// removes markdown bold markers, which 1B models sprinkle freely.
String _clean(String line) => line.replaceAll('**', '').trim();

Iterable<String> _lines(String output) =>
    output.split('\n').map(_clean).where((l) => l.isNotEmpty);

final _flashcardQ = RegExp(
  r'^(?:\d+\s*[.)]\s*)?Q[:.)]\s*(.*)$',
  caseSensitive: false,
);
final _flashcardA = RegExp(
  r'^(?:\d+\s*[.)]\s*)?A[:.)]\s*(.*)$',
  caseSensitive: false,
);
final _explanation = RegExp(
  r'^(?:\d+\s*[.)]\s*)?E[:.)]\s*(.*)$',
  caseSensitive: false,
);
final _numbered = RegExp(r'^\d+\s*[.)]\s*(.*)$');
final _option = RegExp(r'^([A-Da-d])\s*[.)]\s*(.*)$');
final _answerLetter = RegExp(
  r'^(?:ANSWER|Correct answer|Answer)\s*[:\-]?\s*([A-Da-d])\b',
  caseSensitive: false,
);
final _answerText = RegExp(
  r'^(?:ANSWER|Answer)\s*[:\-]\s*(.+)$',
  caseSensitive: false,
);
final _answerBool = RegExp(
  r'^(?:ANSWER|Answer)\s*[:\-]?\s*(True|False)\b',
  caseSensitive: false,
);
final _heading = RegExp(r'^#{1,4}\s+(.+)$');

String _join(String? existing, String next) =>
    existing == null || existing.isEmpty ? next : '$existing $next';

/// Parses `Q:` / `A:` / `E:` blocks into flashcards.
List<GeneratedFlashcard> parseFlashcards(
  String output, {
  required int maxCount,
  required bool includeExplanations,
}) {
  final cards = <GeneratedFlashcard>[];
  String? front, back, explanation;
  var openField = 0; // 0 none, 1 front, 2 back, 3 explanation

  void flush() {
    if (front != null && front!.isNotEmpty && back != null && back!.isNotEmpty) {
      cards.add(
        GeneratedFlashcard(
          front: front!,
          back: back!,
          explanation: includeExplanations ? explanation : null,
        ),
      );
    }
    front = back = explanation = null;
    openField = 0;
  }

  for (final line in _lines(output)) {
    final q = _flashcardQ.firstMatch(line);
    if (q != null) {
      flush();
      front = q.group(1)!;
      openField = 1;
      continue;
    }
    final a = _flashcardA.firstMatch(line);
    if (a != null && front != null) {
      back = a.group(1)!;
      openField = 2;
      continue;
    }
    final e = _explanation.firstMatch(line);
    if (e != null && back != null) {
      explanation = e.group(1)!;
      openField = 3;
      continue;
    }
    // A continuation of whichever field is open.
    switch (openField) {
      case 1:
        front = _join(front, line);
      case 2:
        back = _join(back, line);
      case 3:
        explanation = _join(explanation, line);
    }
    if (cards.length >= maxCount) break;
  }
  flush();
  return cards.take(maxCount).toList();
}

/// Parses a headed summary into one flashcard per section (front =
/// heading, back = section text) — the shape the app presents study
/// material in. Without headings, the whole text becomes one card
/// fronted by [topic].
List<GeneratedFlashcard> parseSummary(
  String output, {
  required int maxCount,
  required String topic,
}) {
  final cards = <GeneratedFlashcard>[];
  String? heading;
  final body = StringBuffer();

  void flush() {
    final text = body.toString().trim();
    final currentHeading = heading;
    if (currentHeading != null && text.isNotEmpty) {
      cards.add(GeneratedFlashcard(front: currentHeading, back: text));
    }
    body.clear();
  }

  for (final line in _lines(output)) {
    final h = _heading.firstMatch(line);
    if (h != null) {
      flush();
      heading = h.group(1)!;
      continue;
    }
    if (heading != null) {
      if (body.isNotEmpty) body.write(' ');
      body.write(line);
    }
  }
  flush();

  if (cards.isEmpty) {
    final text = _lines(output).join(' ').trim();
    if (text.isNotEmpty) {
      return [GeneratedFlashcard(front: topic, back: text)];
    }
    return const [];
  }
  return cards.take(maxCount).toList();
}

/// Accumulates one numbered-question block (shared shape for the
/// three quiz parsers): the prompt, lettered options, the ANSWER
/// line's payload, and an optional explanation.
class _QuizBlock {
  String prompt = '';
  final Map<int, String> options = {};
  String? answerLetter;
  String? answerText;
  String? boolAnswer;
  String? explanation;
  int openField = 0; // 0 none, 1 prompt, 2 option, 3 explanation

  void absorb(String line) {
    final letter = _answerLetter.firstMatch(line);
    if (letter != null) {
      answerLetter = letter.group(1)!.toUpperCase();
      openField = 0;
      return;
    }
    final text = _answerText.firstMatch(line);
    if (text != null) {
      answerText = text.group(1)!;
      openField = 0;
      return;
    }
    final e = _explanation.firstMatch(line);
    if (e != null) {
      explanation = e.group(1)!;
      openField = 3;
      return;
    }
    final option = _option.firstMatch(line);
    if (option != null) {
      final index = option.group(1)!.toUpperCase().codeUnitAt(0) - 65;
      options[index] = option.group(2)!;
      openField = 2;
      return;
    }
    switch (openField) {
      case 1:
        prompt = _join(prompt, line);
      case 2:
        final last = options.keys.fold(-1, (a, b) => a > b ? a : b);
        if (last >= 0) options[last] = _join(options[last], line);
      case 3:
        explanation = _join(explanation, line);
    }
  }
}

List<_QuizBlock> _quizBlocks(String output) {
  final blocks = <_QuizBlock>[];
  _QuizBlock? current;
  for (final line in _lines(output)) {
    final numbered = _numbered.firstMatch(line);
    if (numbered != null) {
      current = _QuizBlock()..prompt = numbered.group(1)!;
      current.openField = 1;
      blocks.add(current);
      continue;
    }
    current?.absorb(line);
  }
  return blocks;
}

/// Parses numbered MCQ blocks (options A–D + `ANSWER: <letter>`).
List<GeneratedQuizQuestion> parseMcqs(
  String output, {
  required int maxCount,
  required bool includeExplanations,
}) {
  final questions = <GeneratedQuizQuestion>[];
  for (final block in _quizBlocks(output)) {
    if (questions.length >= maxCount) break;
    final letter = block.answerLetter;
    if (block.prompt.isEmpty || block.options.length < 2 || letter == null) {
      continue;
    }
    final correct = letter.codeUnitAt(0) - 65;
    if (!block.options.containsKey(correct)) continue;
    final ordered = block.options.keys.toList()..sort();
    questions.add(
      GeneratedQuizQuestion(
        prompt: block.prompt,
        type: QuizQuestionType.mcq,
        options: [for (final i in ordered) block.options[i]!],
        // Remap the letter onto the compacted option list.
        correctIndex: ordered.indexOf(correct),
        explanation: includeExplanations ? block.explanation : null,
      ),
    );
  }
  return questions;
}

/// Parses numbered true/false blocks (`ANSWER: True|False`, with an
/// optional `E:` explanation after the answer).
List<GeneratedQuizQuestion> parseTrueFalse(
  String output, {
  required int maxCount,
  required bool includeExplanations,
}) {
  final questions = <GeneratedQuizQuestion>[];
  var statement = '';
  bool? answer;
  String? explanation;

  void flush() {
    if (statement.isNotEmpty && answer != null) {
      questions.add(
        GeneratedQuizQuestion(
          prompt: statement,
          type: QuizQuestionType.trueFalse,
          options: const ['True', 'False'],
          correctIndex: answer! ? 0 : 1,
          explanation: includeExplanations ? explanation : null,
        ),
      );
    }
    statement = '';
    answer = null;
    explanation = null;
  }

  for (final line in _lines(output)) {
    final numbered = _numbered.firstMatch(line);
    if (numbered != null) {
      flush();
      statement = numbered.group(1)!;
      continue;
    }
    final boolMatch = _answerBool.firstMatch(line);
    if (boolMatch != null && statement.isNotEmpty) {
      answer = boolMatch.group(1)!.toLowerCase() == 'true';
      continue;
    }
    final e = _explanation.firstMatch(line);
    if (e != null && answer != null) {
      explanation = e.group(1)!;
      continue;
    }
    // A continuation of the statement (multi-line statements wrap).
    if (statement.isNotEmpty && answer == null) {
      statement = _join(statement, line);
    }
    if (questions.length >= maxCount) break;
  }
  flush();
  return questions.take(maxCount).toList();
}

/// Parses numbered short-answer blocks (`ANSWER: <expected answer>`).
List<GeneratedQuizQuestion> parseShortAnswers(
  String output, {
  required int maxCount,
  required bool includeExplanations,
}) {
  final questions = <GeneratedQuizQuestion>[];
  for (final block in _quizBlocks(output)) {
    if (questions.length >= maxCount) break;
    final expected = block.answerText;
    if (block.prompt.isEmpty || expected == null || expected.isEmpty) {
      continue;
    }
    questions.add(
      GeneratedQuizQuestion(
        prompt: block.prompt,
        type: QuizQuestionType.shortAnswer,
        expectedAnswer: expected,
        explanation: includeExplanations ? block.explanation : null,
      ),
    );
  }
  return questions;
}

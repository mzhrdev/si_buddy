// Prompt construction for generation jobs: pure Dart, one template
// per material type, requesting exactly the line-based formats that
// generation_output_parser.dart parses. Keeping prompts and parsers
// side by side (and both unit-tested) is what makes a 1B model's
// output usable: the format asked for is the format parsed.

import '../../documents/domain/document_models.dart';
import '../domain/generation_config.dart';

/// Character budget for the source text embedded in a prompt.
///
/// The model's context is 4096 tokens (prompt + reply). At roughly
/// 4 characters per token, 6000 characters of source (~1500 tokens)
/// leaves comfortable room for the instructions and a full reply of
/// generated items. Longer documents are sampled across their
/// sections rather than truncated at the front, so late pages still
/// contribute items.
const int sourceTextBudgetChars = 6000;

/// Builds the full prompt for one generation job from [source]'s
/// extracted text and the user's [config].
String buildGenerationPrompt({
  required ExtractedDocument source,
  required GenerationConfig config,
}) {
  final notes = sampleSourceText(
    source,
    budgetChars: sourceTextBudgetChars,
  );
  final header =
      'You are creating study material from a student\'s notes.\n'
      'Topic: ${config.topic}\n'
      'Difficulty: ${config.difficulty.label}\n'
      'Write everything in ${config.language}.\n'
      'Base every item only on the notes below. Keep each item short '
      'and factual. Output ONLY the items, in exactly the format '
      'shown — no introduction, no closing remarks, no code fences.';
  final task = switch (config.materialType) {
    GenerationMaterialType.flashcards => _flashcardTask(config),
    GenerationMaterialType.mcqs => _mcqTask(config),
    GenerationMaterialType.trueFalse => _trueFalseTask(config),
    GenerationMaterialType.shortAnswers => _shortAnswerTask(config),
    GenerationMaterialType.summaries => _summaryTask(config),
  };
  return '$header\n\n$task\n\nNOTES:\n$notes';
}

/// The NOTES text for a prompt: [source]'s full text when it fits
/// [budgetChars]; otherwise a proportional sample — each section
/// (page/slide) contributes a prefix of itself proportional to its
/// share of the whole, so the sample spans the document instead of
/// stopping at page one. Sections are joined the way the extracted
/// full text joins them (blank lines).
String sampleSourceText(
  ExtractedDocument source, {
  int budgetChars = sourceTextBudgetChars,
}) {
  final full = source.fullText.trim();
  if (full.length <= budgetChars) return full;
  final sections = source.sections
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (sections.length <= 1) return full.substring(0, budgetChars);

  final total = sections.fold<int>(0, (sum, s) => sum + s.length);
  final sampled = <String>[];
  var remaining = budgetChars;
  for (var i = 0; i < sections.length; i++) {
    if (remaining <= 0) break;
    final section = sections[i];
    final isLast = i == sections.length - 1;
    // This section's fair share of the budget; the last section may
    // use whatever is left.
    final share = isLast
        ? remaining
        : (budgetChars * section.length / total).floor();
    final take = share >= section.length ? section.length : share;
    if (take <= 0) continue;
    sampled.add(section.substring(0, take));
    remaining -= take;
  }
  return sampled.join('\n\n');
}

String _explanationLine(GenerationConfig config) => config.includeExplanations
    ? 'E: <one short sentence explaining the answer>\n'
    : '';

String _flashcardTask(GenerationConfig config) {
  return 'Create exactly ${config.count} flashcards about '
      '${config.topic}.\n'
      'Format — one flashcard per block, blocks separated by a blank '
      'line:\n'
      'Q: <a question>\n'
      'A: <the answer>\n'
      '${_explanationLine(config)}';
}

String _mcqTask(GenerationConfig config) {
  return 'Create exactly ${config.count} multiple-choice questions '
      'about ${config.topic}. Give each question four options and '
      'mark the correct one.\n'
      'Format — one question per block, blocks separated by a blank '
      'line:\n'
      '1. <the question>\n'
      'A) <option>\n'
      'B) <option>\n'
      'C) <option>\n'
      'D) <option>\n'
      'ANSWER: <the letter of the correct option, A, B, C or D>\n'
      '${_explanationLine(config)}';
}

String _trueFalseTask(GenerationConfig config) {
  return 'Create exactly ${config.count} true/false statements '
      'about ${config.topic}. Each statement must be clearly true or '
      'clearly false according to the notes.\n'
      'Format — one statement per block, blocks separated by a blank '
      'line:\n'
      '1. <a statement>\n'
      'ANSWER: <True or False>\n'
      '${_explanationLine(config)}';
}

String _shortAnswerTask(GenerationConfig config) {
  return 'Create exactly ${config.count} short-answer questions '
      'about ${config.topic}. Each answer must be a few words only.\n'
      'Format — one question per block, blocks separated by a blank '
      'line:\n'
      '1. <a question>\n'
      'ANSWER: <the expected short answer>\n'
      '${_explanationLine(config)}';
}

String _summaryTask(GenerationConfig config) {
  return 'Write a study summary of the notes about ${config.topic}, '
      'covering the ${config.count} most important ideas. Use one '
      'section per idea.\n'
      'Format:\n'
      '## <a short heading for the idea>\n'
      '<the summary text for that idea>\n'
      '(blank line between sections)';
}

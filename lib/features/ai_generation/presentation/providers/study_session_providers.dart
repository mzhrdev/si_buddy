import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-only study state for a generation result. Nothing here
/// is persisted: decks, cards and quiz answers live for this app
/// session only, until deck/quiz persistence lands. Screens show an
/// honest empty state when no result exists.

/// Index of the flashcard currently shown by the study card
/// screens, into the latest generation's flashcards list.
class StudyCardIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index < 0 ? 0 : index;

  void next(int count) {
    if (count <= 0) return;
    state = (state + 1).clamp(0, count - 1);
  }

  void previous() {
    state = (state - 1).clamp(0, state);
  }

  void reset() => state = 0;
}

final studyCardIndexProvider =
    NotifierProvider<StudyCardIndexNotifier, int>(
      StudyCardIndexNotifier.new,
    );

/// Answers chosen on MCQ / true-false questions, keyed by the
/// question prompt, so the results screen can score the session.
class QuizAnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void answer(String prompt, int optionIndex) {
    state = {...state, prompt: optionIndex};
  }

  void clear() => state = const {};
}

final quizAnswersProvider =
    NotifierProvider<QuizAnswersNotifier, Map<String, int>>(
      QuizAnswersNotifier.new,
    );

/// Self-ratings on flashcards, keyed by card index ('Easy',
/// 'Medium' or 'Hard'), so the session summary can count them.
class CardRatingsNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => const {};

  void rate(int index, String rating) {
    state = {...state, index: rating};
  }

  void clear() => state = const {};
}

final cardRatingsProvider =
    NotifierProvider<CardRatingsNotifier, Map<int, String>>(
      CardRatingsNotifier.new,
    );

/// Index of the question shown by the answer review screen, into
/// the latest generation's questions list.
class ReviewIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index < 0 ? 0 : index;

  void next(int count) {
    if (count <= 0) return;
    state = (state + 1).clamp(0, count - 1);
  }

  void previous() {
    state = (state - 1).clamp(0, state);
  }

  void reset() => state = 0;
}

final reviewIndexProvider =
    NotifierProvider<ReviewIndexNotifier, int>(ReviewIndexNotifier.new);

/// Free-text answers on short-answer questions, keyed by prompt.
class QuizShortAnswersNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void answer(String prompt, String text) {
    state = {...state, prompt: text};
  }

  void clear() => state = const {};
}

final quizShortAnswersProvider =
    NotifierProvider<QuizShortAnswersNotifier, Map<String, String>>(
      QuizShortAnswersNotifier.new,
    );

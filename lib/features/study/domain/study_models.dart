// Domain models for persisted study data: decks, cards, quiz
// questions, attempts, reviews, sessions and revisions. Plain Dart
// classes — the data layer maps drift rows into these types and the
// presentation layer only ever sees these types. Nothing here is
// session-only: every model is backed by a drift table (schema v2).

import '../../ai_generation/domain/generation_config.dart';
import '../../ai_generation/domain/generation_models.dart';

/// One generated study set: a flashcard deck or a quiz produced from
/// a document. A document can have many decks (regenerating creates
/// a new one).
class StudyDeck {
  const StudyDeck({
    required this.id,
    required this.documentId,
    required this.title,
    required this.materialType,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int documentId;
  final String title;
  final GenerationMaterialType materialType;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True for the quiz material types (MCQs, true/false, short
  /// answers); false for flashcards and summaries.
  bool get isQuiz => materialType.isQuiz;
}

/// One persisted flashcard inside a deck, in generation order.
class StudyFlashcard {
  const StudyFlashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.explanation,
    required this.sortOrder,
  });

  final int id;
  final int deckId;
  final String front;
  final String back;
  final String? explanation;
  final int sortOrder;

  GeneratedFlashcard get asGenerated =>
      GeneratedFlashcard(front: front, back: back, explanation: explanation);
}

/// One persisted quiz question inside a deck, in generation order.
class StudyQuestion {
  const StudyQuestion({
    required this.id,
    required this.deckId,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.correctIndex,
    this.expectedAnswer,
    this.explanation,
    required this.sortOrder,
  });

  final int id;
  final int deckId;
  final String prompt;
  final QuizQuestionType type;
  final List<String> options;
  final int? correctIndex;
  final String? expectedAnswer;
  final String? explanation;
  final int sortOrder;

  GeneratedQuizQuestion get asGenerated => GeneratedQuizQuestion(
    prompt: prompt,
    type: type,
    options: options,
    correctIndex: correctIndex,
    expectedAnswer: expectedAnswer,
    explanation: explanation,
  );
}

/// One attempt at a quiz deck. An attempt with a null [completedAt]
/// is an unfinished session the user can resume from [currentIndex].
class QuizAttemptRecord {
  const QuizAttemptRecord({
    required this.id,
    required this.deckId,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.totalQuestions,
    required this.currentIndex,
  });

  final int id;
  final int deckId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? score;
  final int totalQuestions;
  final int currentIndex;

  bool get isCompleted => completedAt != null;
}

/// One answer given inside an attempt.
class QuestionAnswerRecord {
  const QuestionAnswerRecord({
    required this.id,
    required this.attemptId,
    required this.questionId,
    this.selectedIndex,
    this.answerText,
    this.isCorrect,
    required this.answeredAt,
  });

  final int id;
  final int attemptId;
  final int questionId;
  final int? selectedIndex;
  final String? answerText;

  /// Null for answers that are recorded but not scored (short
  /// answers).
  final bool? isCorrect;
  final DateTime answeredAt;
}

/// One study session (a run through a deck, or a quiz attempt
/// window), the raw material for tracked study minutes.
class StudySessionRecord {
  const StudySessionRecord({
    required this.id,
    this.deckId,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.cardsReviewed,
    required this.type,
  });

  final int id;
  final int? deckId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int cardsReviewed;

  /// `flashcards` or `quiz`.
  final String type;
}

/// What kind of unfinished study work a deck holds.
enum IncompleteActivityKind {
  /// A quiz attempt was started but never finished; the user can
  /// resume from the attempt's current question.
  quizIncomplete,

  /// A deck was generated but never studied at all.
  notStarted,

  /// A flashcard deck was partly reviewed; some cards are still
  /// unreviewed.
  flashcardsInProgress,
}

/// The most recent unfinished study work, for "Pick up where you
/// left off": one deck, what kind of work is outstanding, and how
/// far along it is.
class IncompleteActivity {
  const IncompleteActivity({
    required this.deck,
    required this.kind,
    required this.currentIndex,
    required this.totalItems,
  });

  final StudyDeck deck;
  final IncompleteActivityKind kind;

  /// Resume position: the quiz attempt's current question index, or
  /// 0 for a deck that was never started.
  final int currentIndex;
  final int totalItems;

  /// Progress as a fraction, for the Pick Up card.
  double get fraction =>
      totalItems == 0 ? 0 : (currentIndex / totalItems).clamp(0.0, 1.0);
}

/// A finished quiz attempt with its deck, for the study history.
class CompletedAttempt {
  const CompletedAttempt({required this.attempt, required this.deckTitle});

  final QuizAttemptRecord attempt;

  /// The deck's title at read time.
  final String deckTitle;
}

/// A scheduled revision of a deck (the planner's upcoming entries).
class RevisionRecord {
  const RevisionRecord({
    required this.id,
    required this.deckId,
    required this.scheduledAt,
    this.note,
    required this.reminderEnabled,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final int deckId;
  final DateTime scheduledAt;
  final String? note;
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}

/// Genuine study statistics, computed from persisted rows only.
/// Every count is 0 when there is no recorded activity yet — never
/// a sample value.
class StudyStats {
  const StudyStats({
    required this.totalFlashcardsGenerated,
    required this.totalQuizzesGenerated,
    required this.cardsReviewed,
    required this.totalQuizzesAttempted,
    required this.quizzesCompleted,
    required this.quizCompletionRate,
    required this.averageQuizScore,
    required this.totalStudySeconds,
    required this.studiedTodaySeconds,
    required this.sessionsToday,
    required this.streakDays,
  });

  /// Flashcards (and summary sections) generated across all decks.
  final int totalFlashcardsGenerated;

  /// Quiz decks generated.
  final int totalQuizzesGenerated;

  /// Flashcards actually reviewed (self-rated).
  final int cardsReviewed;

  /// Quiz attempts started.
  final int totalQuizzesAttempted;

  /// Quiz attempts finished.
  final int quizzesCompleted;

  /// Completed attempts / started attempts, 0 when none started.
  final double quizCompletionRate;

  /// Mean score as a fraction (0–1) over completed attempts, null
  /// when no attempt has completed yet.
  final double? averageQuizScore;

  /// Tracked study time, in seconds.
  final int totalStudySeconds;

  /// Tracked study time today (local calendar day), in seconds.
  /// This is what the Home daily-goal bar measures against.
  final int studiedTodaySeconds;

  /// Study sessions started today (local calendar day).
  final int sessionsToday;

  /// Consecutive calendar days with recorded study activity
  /// (a review, a session, or a completed attempt), counting back
  /// from today — or from yesterday when nothing is recorded yet
  /// today, so the streak does not die at midnight.
  final int streakDays;

  /// Tracked study time, in whole minutes.
  int get totalStudyMinutes => totalStudySeconds ~/ 60;

  /// Tracked study time today, in whole minutes.
  int get studiedTodayMinutes => studiedTodaySeconds ~/ 60;

  static const empty = StudyStats(
    totalFlashcardsGenerated: 0,
    totalQuizzesGenerated: 0,
    cardsReviewed: 0,
    totalQuizzesAttempted: 0,
    quizzesCompleted: 0,
    quizCompletionRate: 0,
    averageQuizScore: null,
    totalStudySeconds: 0,
    studiedTodaySeconds: 0,
    sessionsToday: 0,
    streakDays: 0,
  );
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../ai_generation/domain/generation_config.dart';
import '../../ai_generation/domain/generation_models.dart';
import '../domain/study_models.dart';

/// The study feature's gateway to persisted study data: generated
/// decks and their items, quiz attempts and answers, card reviews,
/// study sessions and scheduled revisions. Everything the Home,
/// Library, Study and Statistics screens calculate comes from here —
/// nothing is held only in memory any more.
abstract class StudyRepository {
  // -- Decks -------------------------------------------------------

  /// Persists one completed generation result as a deck and returns
  /// its id. Flashcards jobs fill [flashcards], quiz jobs fill
  /// [questions]; the other list stays empty. Summaries arrive as
  /// flashcards (see `parseSummary`).
  Future<int> saveDeck({
    required int documentId,
    required String title,
    required GenerationMaterialType materialType,
    required List<GeneratedFlashcard> flashcards,
    required List<GeneratedQuizQuestion> questions,
  });

  /// Deletes a deck and, via foreign keys, its cards, questions,
  /// attempts, answers, reviews and revisions.
  Future<void> deleteDeck(int deckId);

  /// All decks, newest first, streamed as they change.
  Stream<List<StudyDeck>> watchDecks();

  /// A document's decks, newest first, streamed as they change.
  Stream<List<StudyDeck>> watchDecksForDocument(int documentId);

  /// One deck, or null when it no longer exists.
  Future<StudyDeck?> getDeck(int deckId);

  /// A deck's flashcards, in generation order.
  Future<List<StudyFlashcard>> getFlashcards(int deckId);

  /// A deck's quiz questions, in generation order.
  Future<List<StudyQuestion>> getQuestions(int deckId);

  /// How many study sets a document has (its deck count), streamed.
  Stream<int> watchDeckCountForDocument(int documentId);

  /// Updates one persisted flashcard (the card editor's Save).
  Future<void> updateFlashcard(int cardId, String front, String back);

  // -- Quiz attempts ----------------------------------------------

  /// Starts an attempt on a quiz deck and returns its id.
  Future<int> startAttempt({required int deckId, required int totalQuestions});

  /// Records (or replaces) one answer inside an attempt. Answers
  /// are written as the user gives them, so an interrupted quiz
  /// keeps everything answered so far.
  Future<void> recordAnswer({
    required int attemptId,
    required int questionId,
    int? selectedIndex,
    String? answerText,
    bool? isCorrect,
  });

  /// Moves an attempt's resume position.
  Future<void> updateAttemptProgress(int attemptId, int currentIndex);

  /// Marks an attempt finished with its score (correct answers).
  Future<void> completeAttempt(int attemptId, int score);

  /// A deck's unfinished attempt, if one exists.
  Future<QuizAttemptRecord?> getIncompleteAttempt(int deckId);

  /// A deck's attempts, newest first.
  Future<List<QuizAttemptRecord>> listAttemptsForDeck(int deckId);

  /// An attempt's recorded answers, in answer order.
  Future<List<QuestionAnswerRecord>> getAnswers(int attemptId);

  // -- Card reviews -------------------------------------------------

  /// Records one self-rating (Easy / Medium / Hard) on a flashcard.
  Future<void> recordReview({required int cardId, required String rating});

  // -- Study sessions ----------------------------------------------

  /// Starts a timed study session (flashcard run or quiz window)
  /// and returns its id.
  Future<int> startSession({int? deckId, required String type});

  /// Ends a session with its tracked duration and cards reviewed.
  Future<void> endSession(
    int sessionId, {
    required int durationSeconds,
    required int cardsReviewed,
  });

  // -- Revisions ----------------------------------------------------

  /// Schedules a revision of a deck and returns its id.
  Future<int> scheduleRevision({
    required int deckId,
    required DateTime scheduledAt,
    String? note,
    bool reminderEnabled = true,
  });

  /// Edits a scheduled revision.
  Future<void> updateRevision(
    int revisionId, {
    DateTime? scheduledAt,
    String? note,
    bool? reminderEnabled,
  });

  /// Marks a revision done.
  Future<void> completeRevision(int revisionId);

  /// Deletes a scheduled revision.
  Future<void> deleteRevision(int revisionId);

  /// Upcoming (not completed, not past) revisions, soonest first,
  /// streamed as they change.
  Stream<List<RevisionRecord>> watchUpcomingRevisions();

  /// Daily study activity for the last [days] local calendar days,
  /// oldest first, including days with no activity (zeros): tracked
  /// study time, cards reviewed and quizzes completed per day.
  /// Only finished sessions count toward study time.
  Future<List<DailyActivity>> getDailyActivity({int days = 7});

  /// Removes a study session entirely. The session tracker uses
  /// this for sessions that never became real studying (abandoned
  /// within seconds with nothing reviewed).
  Future<void> deleteSession(int sessionId);

  /// Study-content matches for the library's inline search:
  /// persisted flashcards and quiz questions whose text contains
  /// [query] (case-insensitive), newest deck first. One match per
  /// matching item, capped at [limit].
  Future<List<StudySearchMatch>> searchStudyContent(
    String query, {
    int limit = 12,
  });

  // -- Statistics ---------------------------------------------------

  /// Genuine study statistics computed from persisted rows only.
  Future<StudyStats> getStats();

  /// The most recent unfinished study work, for "Pick up where you
  /// left off": an unfinished quiz attempt first (the most recent
  /// one), otherwise the most recent deck that was never studied.
  /// Null when there is no unfinished work.
  Future<IncompleteActivity?> getLatestIncompleteActivity();

  /// Finished quiz attempts, newest first, with their deck titles —
  /// the study history. Limited to [limit] entries.
  Future<List<CompletedAttempt>> listCompletedAttempts({int limit = 5});

  /// Deletes every persisted study row — decks (with their cards,
  /// questions, attempts, answers and reviews), sessions, revisions
  /// and subjects — for "Clear All Local Data". Documents are
  /// deleted separately (their delete also removes stored files and
  /// extracted text).
  Future<void> deleteAllStudyData();
}

class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl({required this.db});

  final AppDatabase db;

  // -- Mapping ------------------------------------------------------

  static GenerationMaterialType _materialType(String name) =>
      GenerationMaterialType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => GenerationMaterialType.flashcards,
      );

  static QuizQuestionType _questionType(String name) => QuizQuestionType.values
      .firstWhere((e) => e.name == name, orElse: () => QuizQuestionType.mcq);

  static StudyDeck _toDeck(DbDeck row) => StudyDeck(
    id: row.id,
    documentId: row.documentId,
    title: row.title,
    materialType: _materialType(row.materialType),
    totalItems: row.totalItems,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static StudyFlashcard _toFlashcard(DbFlashcard row) => StudyFlashcard(
    id: row.id,
    deckId: row.deckId,
    front: row.front,
    back: row.back,
    explanation: row.explanation,
    sortOrder: row.sortOrder,
  );

  static StudyQuestion _toQuestion(DbQuizQuestion row) {
    final options = (jsonDecode(row.optionsJson) as List)
        .map((e) => e.toString())
        .toList();
    return StudyQuestion(
      id: row.id,
      deckId: row.deckId,
      prompt: row.prompt,
      type: _questionType(row.type),
      options: options,
      correctIndex: row.correctIndex,
      expectedAnswer: row.expectedAnswer,
      explanation: row.explanation,
      sortOrder: row.sortOrder,
    );
  }

  static QuizAttemptRecord _toAttempt(DbQuizAttempt row) => QuizAttemptRecord(
    id: row.id,
    deckId: row.deckId,
    startedAt: row.startedAt,
    completedAt: row.completedAt,
    score: row.score,
    totalQuestions: row.totalQuestions,
    currentIndex: row.currentIndex,
  );

  static QuestionAnswerRecord _toAnswer(DbQuestionAnswer row) =>
      QuestionAnswerRecord(
        id: row.id,
        attemptId: row.attemptId,
        questionId: row.questionId,
        selectedIndex: row.selectedIndex,
        answerText: row.answerText,
        isCorrect: row.isCorrect,
        answeredAt: row.answeredAt,
      );

  static RevisionRecord _toRevision(DbRevision row) => RevisionRecord(
    id: row.id,
    deckId: row.deckId,
    scheduledAt: row.scheduledAt,
    note: row.note,
    reminderEnabled: row.reminderEnabled,
    createdAt: row.createdAt,
    completedAt: row.completedAt,
  );

  // -- Decks ---------------------------------------------------------

  @override
  Future<int> saveDeck({
    required int documentId,
    required String title,
    required GenerationMaterialType materialType,
    required List<GeneratedFlashcard> flashcards,
    required List<GeneratedQuizQuestion> questions,
  }) async {
    final now = DateTime.now();
    final deckId = await db
        .into(db.dbDecks)
        .insert(
          DbDecksCompanion.insert(
            documentId: documentId,
            title: title,
            materialType: materialType.name,
            totalItems: flashcards.length + questions.length,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.batch((batch) {
      for (var i = 0; i < flashcards.length; i++) {
        final card = flashcards[i];
        batch.insert(
          db.dbFlashcards,
          DbFlashcardsCompanion.insert(
            deckId: deckId,
            front: card.front,
            back: card.back,
            explanation: Value(card.explanation),
            sortOrder: i,
          ),
        );
      }
      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        batch.insert(
          db.dbQuizQuestions,
          DbQuizQuestionsCompanion.insert(
            deckId: deckId,
            prompt: question.prompt,
            type: question.type.name,
            optionsJson: jsonEncode(question.options),
            correctIndex: Value(question.correctIndex),
            expectedAnswer: Value(question.expectedAnswer),
            explanation: Value(question.explanation),
            sortOrder: i,
          ),
        );
      }
    });
    return deckId;
  }

  @override
  Future<void> deleteDeck(int deckId) async {
    await (db.delete(db.dbDecks)..where((t) => t.id.equals(deckId))).go();
  }

  @override
  Stream<List<StudyDeck>> watchDecks() {
    final query = db.select(db.dbDecks)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDeck).toList());
  }

  @override
  Stream<List<StudyDeck>> watchDecksForDocument(int documentId) {
    final query = db.select(db.dbDecks)
      ..where((t) => t.documentId.equals(documentId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDeck).toList());
  }

  @override
  Future<StudyDeck?> getDeck(int deckId) async {
    final row = await (db.select(
      db.dbDecks,
    )..where((t) => t.id.equals(deckId))).getSingleOrNull();
    return row == null ? null : _toDeck(row);
  }

  @override
  Future<List<StudyFlashcard>> getFlashcards(int deckId) async {
    final rows =
        await (db.select(db.dbFlashcards)
              ..where((t) => t.deckId.equals(deckId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_toFlashcard).toList();
  }

  @override
  Future<List<StudyQuestion>> getQuestions(int deckId) async {
    final rows =
        await (db.select(db.dbQuizQuestions)
              ..where((t) => t.deckId.equals(deckId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_toQuestion).toList();
  }

  @override
  Stream<int> watchDeckCountForDocument(int documentId) {
    return watchDecksForDocument(documentId).map((decks) => decks.length);
  }

  @override
  Future<void> updateFlashcard(int cardId, String front, String back) async {
    await (db.update(db.dbFlashcards)..where((t) => t.id.equals(cardId))).write(
      DbFlashcardsCompanion(front: Value(front), back: Value(back)),
    );
  }

  // -- Quiz attempts --------------------------------------------------

  @override
  Future<int> startAttempt({
    required int deckId,
    required int totalQuestions,
  }) async {
    return db
        .into(db.dbQuizAttempts)
        .insert(
          DbQuizAttemptsCompanion.insert(
            deckId: deckId,
            startedAt: DateTime.now(),
            totalQuestions: totalQuestions,
          ),
        );
  }

  @override
  Future<void> recordAnswer({
    required int attemptId,
    required int questionId,
    int? selectedIndex,
    String? answerText,
    bool? isCorrect,
  }) async {
    final existing =
        await (db.select(db.dbQuestionAnswers)..where(
              (t) =>
                  t.attemptId.equals(attemptId) &
                  t.questionId.equals(questionId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (db.update(
        db.dbQuestionAnswers,
      )..where((t) => t.id.equals(existing.id))).write(
        DbQuestionAnswersCompanion(
          selectedIndex: Value(selectedIndex),
          answerText: Value(answerText),
          isCorrect: Value(isCorrect),
          answeredAt: Value(DateTime.now()),
        ),
      );
    } else {
      await db
          .into(db.dbQuestionAnswers)
          .insert(
            DbQuestionAnswersCompanion.insert(
              attemptId: attemptId,
              questionId: questionId,
              selectedIndex: Value(selectedIndex),
              answerText: Value(answerText),
              isCorrect: Value(isCorrect),
              answeredAt: DateTime.now(),
            ),
          );
    }
  }

  @override
  Future<void> updateAttemptProgress(int attemptId, int currentIndex) async {
    await (db.update(db.dbQuizAttempts)..where((t) => t.id.equals(attemptId)))
        .write(DbQuizAttemptsCompanion(currentIndex: Value(currentIndex)));
  }

  @override
  Future<void> completeAttempt(int attemptId, int score) async {
    await (db.update(
      db.dbQuizAttempts,
    )..where((t) => t.id.equals(attemptId))).write(
      DbQuizAttemptsCompanion(
        completedAt: Value(DateTime.now()),
        score: Value(score),
      ),
    );
  }

  @override
  Future<QuizAttemptRecord?> getIncompleteAttempt(int deckId) async {
    final row =
        await (db.select(db.dbQuizAttempts)
              ..where((t) => t.deckId.equals(deckId) & t.completedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toAttempt(row);
  }

  @override
  Future<List<QuizAttemptRecord>> listAttemptsForDeck(int deckId) async {
    final rows =
        await (db.select(db.dbQuizAttempts)
              ..where((t) => t.deckId.equals(deckId))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
            .get();
    return rows.map(_toAttempt).toList();
  }

  @override
  Future<List<QuestionAnswerRecord>> getAnswers(int attemptId) async {
    final rows =
        await (db.select(db.dbQuestionAnswers)
              ..where((t) => t.attemptId.equals(attemptId))
              ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
            .get();
    return rows.map(_toAnswer).toList();
  }

  // -- Card reviews ----------------------------------------------------

  @override
  Future<void> recordReview({
    required int cardId,
    required String rating,
  }) async {
    await db
        .into(db.dbCardReviews)
        .insert(
          DbCardReviewsCompanion.insert(
            cardId: cardId,
            rating: rating,
            reviewedAt: DateTime.now(),
          ),
        );
  }

  // -- Study sessions ----------------------------------------------------

  @override
  Future<int> startSession({int? deckId, required String type}) async {
    return db
        .into(db.dbStudySessions)
        .insert(
          DbStudySessionsCompanion.insert(
            deckId: Value(deckId),
            startedAt: DateTime.now(),
            type: type,
          ),
        );
  }

  @override
  Future<void> endSession(
    int sessionId, {
    required int durationSeconds,
    required int cardsReviewed,
  }) async {
    await (db.update(
      db.dbStudySessions,
    )..where((t) => t.id.equals(sessionId))).write(
      DbStudySessionsCompanion(
        endedAt: Value(DateTime.now()),
        durationSeconds: Value(durationSeconds),
        cardsReviewed: Value(cardsReviewed),
      ),
    );
  }

  // -- Revisions -----------------------------------------------------------

  @override
  Future<int> scheduleRevision({
    required int deckId,
    required DateTime scheduledAt,
    String? note,
    bool reminderEnabled = true,
  }) async {
    return db
        .into(db.dbRevisions)
        .insert(
          DbRevisionsCompanion.insert(
            deckId: deckId,
            scheduledAt: scheduledAt,
            note: Value(note),
            reminderEnabled: Value(reminderEnabled),
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> updateRevision(
    int revisionId, {
    DateTime? scheduledAt,
    String? note,
    bool? reminderEnabled,
  }) async {
    await (db.update(
      db.dbRevisions,
    )..where((t) => t.id.equals(revisionId))).write(
      DbRevisionsCompanion(
        scheduledAt: scheduledAt == null
            ? const Value.absent()
            : Value(scheduledAt),
        note: note == null ? const Value.absent() : Value(note),
        reminderEnabled: reminderEnabled == null
            ? const Value.absent()
            : Value(reminderEnabled),
      ),
    );
  }

  @override
  Future<void> completeRevision(int revisionId) async {
    await (db.update(db.dbRevisions)..where((t) => t.id.equals(revisionId)))
        .write(DbRevisionsCompanion(completedAt: Value(DateTime.now())));
  }

  @override
  Future<void> deleteRevision(int revisionId) async {
    await (db.delete(
      db.dbRevisions,
    )..where((t) => t.id.equals(revisionId))).go();
  }

  @override
  Stream<List<RevisionRecord>> watchUpcomingRevisions() {
    final query = db.select(db.dbRevisions)
      ..where(
        (t) =>
            t.completedAt.isNull() &
            t.scheduledAt.isBiggerOrEqualValue(DateTime.now()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]);
    return query.watch().map((rows) => rows.map(_toRevision).toList());
  }

  // -- Statistics -----------------------------------------------------------

  @override
  Future<List<DailyActivity>> getDailyActivity({int days = 7}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(Duration(days: days - 1));
    final sessions = await db.select(db.dbStudySessions).get();
    final reviews = await db.select(db.dbCardReviews).get();
    final attempts = await db.select(db.dbQuizAttempts).get();

    DateTime dayOf(DateTime at) => DateTime(at.year, at.month, at.day);

    final studySeconds = <DateTime, int>{};
    for (final session in sessions) {
      // Only finished sessions carry a duration; an open session
      // contributes nothing until it ends.
      if (session.endedAt == null) continue;
      final day = dayOf(session.startedAt);
      if (day.isBefore(firstDay)) continue;
      studySeconds[day] = (studySeconds[day] ?? 0) + session.durationSeconds;
    }
    final cardsReviewed = <DateTime, int>{};
    for (final review in reviews) {
      final day = dayOf(review.reviewedAt);
      if (day.isBefore(firstDay)) continue;
      cardsReviewed[day] = (cardsReviewed[day] ?? 0) + 1;
    }
    final quizzesCompleted = <DateTime, int>{};
    for (final attempt in attempts) {
      final completedAt = attempt.completedAt;
      if (completedAt == null) continue;
      final day = dayOf(completedAt);
      if (day.isBefore(firstDay)) continue;
      quizzesCompleted[day] = (quizzesCompleted[day] ?? 0) + 1;
    }
    return [
      for (var i = days - 1; i >= 0; i--)
        DailyActivity(
          date: today.subtract(Duration(days: i)),
          studySeconds: studySeconds[today.subtract(Duration(days: i))] ?? 0,
          cardsReviewed: cardsReviewed[today.subtract(Duration(days: i))] ?? 0,
          quizzesCompleted:
              quizzesCompleted[today.subtract(Duration(days: i))] ?? 0,
        ),
    ];
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    await (db.delete(
      db.dbStudySessions,
    )..where((t) => t.id.equals(sessionId))).go();
  }

  @override
  Future<void> deleteAllStudyData() async {
    // Child rows first (foreign keys cascade anyway, but explicit
    // order keeps the wipe correct even if a cascade is ever
    // relaxed), then the parents.
    await db.delete(db.dbQuestionAnswers).go();
    await db.delete(db.dbQuizAttempts).go();
    await db.delete(db.dbCardReviews).go();
    await db.delete(db.dbQuizQuestions).go();
    await db.delete(db.dbFlashcards).go();
    await db.delete(db.dbStudySessions).go();
    await db.delete(db.dbRevisions).go();
    await db.delete(db.dbDecks).go();
    await db.delete(db.dbSubjects).go();
  }

  @override
  Future<List<StudySearchMatch>> searchStudyContent(
    String query, {
    int limit = 12,
  }) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final decks =
        await (db.select(db.dbDecks)..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              // Newer deck wins when two decks share a timestamp.
              (t) => OrderingTerm.desc(t.id),
            ]))
            .get();
    final matches = <StudySearchMatch>[];
    for (final row in decks) {
      if (matches.length >= limit) break;
      final deck = _toDeck(row);
      if (deck.isQuiz) {
        final questions = await getQuestions(deck.id);
        for (final question in questions) {
          if (matches.length >= limit) break;
          if (question.prompt.toLowerCase().contains(needle)) {
            matches.add(StudySearchMatch(deck: deck, snippet: question.prompt));
          }
        }
      } else {
        final cards = await getFlashcards(deck.id);
        for (final card in cards) {
          if (matches.length >= limit) break;
          if (card.front.toLowerCase().contains(needle) ||
              card.back.toLowerCase().contains(needle)) {
            matches.add(StudySearchMatch(deck: deck, snippet: card.front));
          }
        }
      }
    }
    return matches;
  }

  @override
  Future<StudyStats> getStats() async {
    final flashcards = await db.select(db.dbFlashcards).get();
    final decks = await db.select(db.dbDecks).get();
    final reviews = await db.select(db.dbCardReviews).get();
    final attempts = await db.select(db.dbQuizAttempts).get();
    final sessions = await db.select(db.dbStudySessions).get();

    final quizDecks = decks.where((d) => _materialType(d.materialType).isQuiz);
    final completed = attempts.where((a) => a.completedAt != null).toList();
    final scored = completed.where((a) => a.score != null).toList();
    final averageScore = scored.isEmpty
        ? null
        : scored
                  .map((a) => a.score! / a.totalQuestions)
                  .reduce((a, b) => a + b) /
              scored.length;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionsTodayList = sessions.where((s) {
      final day = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      return day == today;
    }).toList();

    return StudyStats(
      totalFlashcardsGenerated: flashcards.length,
      totalQuizzesGenerated: quizDecks.length,
      cardsReviewed: reviews.length,
      totalQuizzesAttempted: attempts.length,
      quizzesCompleted: completed.length,
      quizCompletionRate: attempts.isEmpty
          ? 0
          : completed.length / attempts.length,
      averageQuizScore: averageScore,
      totalStudySeconds: sessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      ),
      studiedTodaySeconds: sessionsTodayList.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      ),
      sessionsToday: sessionsTodayList.length,
      streakDays: _streakDays(reviews, sessions, completed, now),
    );
  }

  @override
  Future<IncompleteActivity?> getLatestIncompleteActivity() async {
    // An unfinished quiz attempt first: the most recent one wins.
    final open =
        await (db.select(db.dbQuizAttempts)
              ..where((t) => t.completedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (open != null) {
      final deck = await getDeck(open.deckId);
      if (deck != null) {
        return IncompleteActivity(
          deck: deck,
          kind: IncompleteActivityKind.quizIncomplete,
          currentIndex: open.currentIndex,
          totalItems: open.totalQuestions,
        );
      }
    }
    // Otherwise the most recent deck with unfinished work: a
    // flashcard deck whose cards are not all reviewed, or a quiz
    // deck with no attempt at all.
    final decks = await (db.select(
      db.dbDecks,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    for (final row in decks) {
      final deck = _toDeck(row);
      if (!deck.isQuiz) {
        final cards = await (db.select(
          db.dbFlashcards,
        )..where((t) => t.deckId.equals(deck.id))).get();
        if (cards.isEmpty) continue;
        final cardIds = cards.map((c) => c.id).toList();
        final reviews = await (db.select(
          db.dbCardReviews,
        )..where((t) => t.cardId.isIn(cardIds))).get();
        final reviewed = reviews.map((r) => r.cardId).toSet().length;
        if (reviewed < cards.length) {
          return IncompleteActivity(
            deck: deck,
            kind: reviewed == 0
                ? IncompleteActivityKind.notStarted
                : IncompleteActivityKind.flashcardsInProgress,
            currentIndex: reviewed,
            totalItems: cards.length,
          );
        }
      } else {
        final attempts =
            await (db.select(db.dbQuizAttempts)
                  ..where((t) => t.deckId.equals(deck.id))
                  ..limit(1))
                .get();
        if (attempts.isEmpty) {
          return IncompleteActivity(
            deck: deck,
            kind: IncompleteActivityKind.notStarted,
            currentIndex: 0,
            totalItems: deck.totalItems,
          );
        }
      }
    }
    return null;
  }

  @override
  Future<List<CompletedAttempt>> listCompletedAttempts({int limit = 5}) async {
    final rows =
        await (db.select(db.dbQuizAttempts)
              ..where((t) => t.completedAt.isNotNull())
              ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
              ..limit(limit))
            .get();
    final completed = <CompletedAttempt>[];
    for (final row in rows) {
      final deck = await getDeck(row.deckId);
      completed.add(
        CompletedAttempt(
          attempt: _toAttempt(row),
          deckTitle: deck?.title ?? 'Quiz',
        ),
      );
    }
    return completed;
  }

  /// Consecutive calendar days with recorded study activity, walking
  /// back from today — or from yesterday when nothing is recorded
  /// yet today, so the streak does not die at midnight.
  static int _streakDays(
    List<DbCardReview> reviews,
    List<DbStudySession> sessions,
    List<DbQuizAttempt> completedAttempts,
    DateTime now,
  ) {
    final days = <DateTime>{};
    DateTime dayOf(DateTime at) => DateTime(at.year, at.month, at.day);
    for (final review in reviews) {
      days.add(dayOf(review.reviewedAt));
    }
    for (final session in sessions) {
      days.add(dayOf(session.startedAt));
    }
    for (final attempt in completedAttempts) {
      days.add(dayOf(attempt.completedAt!));
    }
    if (days.isEmpty) return 0;
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Library folders (subjects) documents are organised into.
class DbFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

/// Subject categories assigned to documents (Biology, Chemistry,
/// Research, …). A document with no subject reads as "Unassigned".
/// Distinct from [DbFolders]: folders are user-created containers a
/// document lives in; a subject is a category label on the document.
class DbSubjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
}

/// One imported document. The original file itself is copied into the
/// app's private storage; [storedPath] points at that copy.
class DbDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get originalFileName => text()();

  /// `DocumentFormat.name` of the document (`pdf` / `pptx`).
  TextColumn get format => text()();
  IntColumn get sizeBytes => integer()();

  /// Pages for a PDF, slides for a PPTX.
  IntColumn get pageCount => integer()();
  IntColumn get folderId => integer().nullable().references(
    DbFolders,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get subjectId => integer().nullable().references(
    DbSubjects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get storedPath => text()();
}

/// The text extracted from a document (one row per document).
class DbExtractedTexts extends Table {
  IntColumn get documentId => integer().references(
    DbDocuments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get fullText => text()();
  IntColumn get charCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {documentId};
}

/// App-wide key/value settings (onboarding completion, theme mode,
/// daily goal, notification preferences, …). One row per key; values
/// are plain strings so new settings need no migration.
class DbSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// One generated study set: a flashcard deck or a quiz produced from
/// a document. A document can have many decks (regenerating creates
/// a new one); deleting the document deletes its decks.
class DbDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(
    DbDocuments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get title => text()();

  /// `GenerationMaterialType.name` (`flashcards`, `mcqs`,
  /// `trueFalse`, `shortAnswers`, `summaries`).
  TextColumn get materialType => text()();
  IntColumn get totalItems => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// One flashcard inside a deck, in generation order.
class DbFlashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(
    DbDecks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get explanation => text().nullable()();
  IntColumn get sortOrder => integer()();
}

/// One quiz question inside a deck, in generation order. Options are
/// a JSON-encoded list of strings; [correctIndex] applies to MCQ and
/// true/false questions, [expectedAnswer] to short answers.
class DbQuizQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(
    DbDecks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get prompt => text()();

  /// `QuizQuestionType.name` (`mcq`, `trueFalse`, `shortAnswer`).
  TextColumn get type => text()();
  TextColumn get optionsJson => text()();
  IntColumn get correctIndex => integer().nullable()();
  TextColumn get expectedAnswer => text().nullable()();
  TextColumn get explanation => text().nullable()();
  IntColumn get sortOrder => integer()();
}

/// One attempt at a quiz deck. An attempt with a null [completedAt]
/// is an unfinished session the user can resume from [currentIndex].
class DbQuizAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(
    DbDecks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  IntColumn get totalQuestions => integer()();
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
}

/// One answer given inside an attempt. [isCorrect] is null for
/// answers that are recorded but not scored (short answers).
class DbQuestionAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(
    DbQuizAttempts,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get questionId => integer().references(
    DbQuizQuestions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get selectedIndex => integer().nullable()();
  TextColumn get answerText => text().nullable()();
  BoolColumn get isCorrect => boolean().nullable()();
  DateTimeColumn get answeredAt => dateTime()();
}

/// One flashcard review (a self-rating of Easy / Medium / Hard).
/// Reviews are the raw material for "cards reviewed" and streaks.
class DbCardReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().references(
    DbFlashcards,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt => dateTime()();
}

/// One study session (a run through a deck, or a quiz attempt
/// window). Sessions are the raw material for tracked study minutes
/// and "studied today".
class DbStudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().nullable().references(
    DbDecks,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  TextColumn get type => text()();
}

/// A scheduled revision of a deck: the planner's "upcoming
/// revision" entries. [completedAt] marks a done revision.
class DbRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(
    DbDecks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// The app's local database (SQLite via drift).
///
/// Use [AppDatabase.new] with an explicit executor in tests
/// (e.g. `NativeDatabase.memory()`), and [AppDatabase.defaults] in the
/// app, which stores the database in the application documents
/// directory via drift_flutter.
///
/// Schema history:
/// - v1: folders, documents, extracted texts.
/// - v2: settings, subjects, decks, flashcards, quiz questions,
///   attempts, answers, card reviews, study sessions, revisions;
///   `subjectId` added to documents. The v1 → v2 upgrade creates
///   the new tables and the new column, and never touches existing
///   rows — a user's library survives the upgrade untouched.
@DriftDatabase(
  tables: [
    DbFolders,
    DbSubjects,
    DbDocuments,
    DbExtractedTexts,
    DbSettings,
    DbDecks,
    DbFlashcards,
    DbQuizQuestions,
    DbQuizAttempts,
    DbQuestionAnswers,
    DbCardReviews,
    DbStudySessions,
    DbRevisions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The app database at its platform location (`si_buddy.sqlite`).
  factory AppDatabase.defaults() {
    return AppDatabase(driftDatabase(name: 'si_buddy'));
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(dbSettings);
          await m.createTable(dbSubjects);
          await m.createTable(dbDecks);
          await m.createTable(dbFlashcards);
          await m.createTable(dbQuizQuestions);
          await m.createTable(dbQuizAttempts);
          await m.createTable(dbQuestionAnswers);
          await m.createTable(dbCardReviews);
          await m.createTable(dbStudySessions);
          await m.createTable(dbRevisions);
          await m.addColumn(dbDocuments, dbDocuments.subjectId);
        }
      },
      beforeOpen: (details) async {
        // Enforce the folder/document/text foreign keys (SQLite leaves
        // them off by default).
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

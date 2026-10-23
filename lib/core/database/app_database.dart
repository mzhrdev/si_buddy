import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Library folders (subjects) documents are organised into.
class DbFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
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

/// The app's local database (SQLite via drift).
///
/// Use [AppDatabase.new] with an explicit executor in tests
/// (e.g. `NativeDatabase.memory()`), and [AppDatabase.defaults] in the
/// app, which stores the database in the application documents
/// directory via drift_flutter.
@DriftDatabase(tables: [DbFolders, DbDocuments, DbExtractedTexts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The app database at its platform location (`si_buddy.sqlite`).
  factory AppDatabase.defaults() {
    return AppDatabase(driftDatabase(name: 'si_buddy'));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Enforce the folder/document/text foreign keys (SQLite leaves
        // them off by default).
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

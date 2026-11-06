import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';

/// The v1 → v2 migration must preserve the user's library: a database
/// created by the v1 schema (folders, documents, extracted texts)
/// upgrades to v2 with its rows intact and the new tables present.
///
/// The v1 schema is built in the executor's `setup` callback, which
/// runs when the raw connection opens — before drift checks the
/// schema version and runs the upgrade.
void main() {
  test('v1 database upgrades to v2 without losing documents', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE db_folders ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
            'name TEXT NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE db_documents ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
            'title TEXT NOT NULL, '
            'original_file_name TEXT NOT NULL, '
            'format TEXT NOT NULL, '
            'size_bytes INTEGER NOT NULL, '
            'page_count INTEGER NOT NULL, '
            'folder_id INTEGER NULL REFERENCES db_folders (id) '
            'ON DELETE SET NULL, '
            'created_at INTEGER NOT NULL, '
            'updated_at INTEGER NOT NULL, '
            'stored_path TEXT NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE db_extracted_texts ('
            'document_id INTEGER NOT NULL REFERENCES db_documents (id) '
            'ON DELETE CASCADE, '
            'full_text TEXT NOT NULL, '
            'char_count INTEGER NOT NULL, '
            'PRIMARY KEY (document_id))',
          );
          final now = DateTime.now().millisecondsSinceEpoch;
          raw.execute(
            "INSERT INTO db_folders (id, name) VALUES (1, 'Biology')",
          );
          raw.execute(
            "INSERT INTO db_documents (id, title, original_file_name, "
            "format, size_bytes, page_count, folder_id, created_at, "
            "updated_at, stored_path) VALUES (1, 'Cells', 'cells.pdf', "
            "'pdf', 1024, 3, 1, $now, $now, '/tmp/cells.pdf')",
          );
          raw.execute(
            "INSERT INTO db_extracted_texts (document_id, full_text, "
            "char_count) VALUES (1, 'Cells are the basic unit of life.', 34)",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    try {
      // The first query runs the v1 → v2 upgrade.
      final documents = await db.select(db.dbDocuments).get();
      expect(documents, hasLength(1));
      expect(documents.first.title, 'Cells');
      expect(documents.first.folderId, 1);
      expect(documents.first.subjectId, isNull);

      final texts = await db.select(db.dbExtractedTexts).get();
      expect(texts, hasLength(1));
      expect(texts.first.fullText, 'Cells are the basic unit of life.');

      // The new tables exist and are usable.
      for (final table in [
        'db_settings',
        'db_subjects',
        'db_decks',
        'db_flashcards',
        'db_quiz_questions',
        'db_quiz_attempts',
        'db_question_answers',
        'db_card_reviews',
        'db_study_sessions',
        'db_revisions',
      ]) {
        final rows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name = '$table'",
            )
            .get();
        expect(
          rows,
          hasLength(1),
          reason: '$table should exist after upgrade',
        );
      }
    } finally {
      await db.close();
    }
  });

  test('fresh v2 database creates all tables', () async {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 2);
    final decks = await db.select(db.dbDecks).get();
    expect(decks, isEmpty);
    await db.close();
  });
}

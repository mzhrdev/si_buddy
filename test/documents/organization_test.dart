import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/core/database/settings_repository.dart';
import 'package:si_buddy/features/documents/data/document_repository_impl.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late DocumentRepositoryImpl documents;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db: db);
    documents = DocumentRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsRepository', () {
    test('round-trips strings, bools and ints', () async {
      expect(await settings.getString('missing'), isNull);
      await settings.setString(SettingsKeys.themeMode, 'dark');
      expect(await settings.getString(SettingsKeys.themeMode), 'dark');

      await settings.setBool(SettingsKeys.onboardingCompleted, true);
      expect(
        await settings.getBool(SettingsKeys.onboardingCompleted),
        isTrue,
      );

      await settings.setInt(SettingsKeys.dailyGoalMinutes, 30);
      expect(await settings.getInt(SettingsKeys.dailyGoalMinutes), 30);
    });

    test('streams value changes', () async {
      final values = <String?>[];
      final subscription = settings
          .watchString(SettingsKeys.themeMode)
          .listen(values.add);
      await settings.setString(SettingsKeys.themeMode, 'light');
      await settings.setString(SettingsKeys.themeMode, 'system');
      await Future<void>.delayed(Duration.zero);
      expect(values, contains('light'));
      expect(values, contains('system'));
      await subscription.cancel();
    });

    test('remove clears a setting', () async {
      await settings.setString(SettingsKeys.themeMode, 'dark');
      await settings.remove(SettingsKeys.themeMode);
      expect(await settings.getString(SettingsKeys.themeMode), isNull);
    });
  });

  group('folders and subjects', () {
    test('creates folders and returns the existing id on duplicates',
        () async {
      final first = await documents.createFolder('Biology');
      final second = await documents.createFolder('Biology');
      expect(second, first);
      expect(
        (await documents.listFolders()).map((f) => f.name),
        ['Biology'],
      );
    });

    test('renaming a folder rejects a duplicate name', () async {
      final biology = await documents.createFolder('Biology');
      await documents.createFolder('Chemistry');
      await expectLater(
        () => documents.renameFolder(biology, 'Chemistry'),
        throwsStateError,
      );
      await documents.renameFolder(biology, 'Life Sciences');
      expect(
        (await documents.listFolders()).map((f) => f.name),
        contains('Life Sciences'),
      );
    });

    test('deleting a folder unfiles its documents instead of deleting them',
        () async {
      final folderId = await documents.createFolder('Biology');
      final documentId = await db
          .into(db.dbDocuments)
          .insert(
            DbDocumentsCompanion.insert(
              title: 'Cells',
              originalFileName: 'cells.pdf',
              format: 'pdf',
              sizeBytes: 10,
              pageCount: 1,
              folderId: Value(folderId),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              storedPath: '/tmp/cells.pdf',
            ),
          );
      await documents.deleteFolder(folderId);
      expect(await documents.listFolders(), isEmpty);
      final docs = await documents.listDocuments();
      expect(docs, hasLength(1));
      expect(docs.first.id, documentId);
      expect(docs.first.folderId, isNull);
    });

    test('subjects round-trip and deleting one unassigns documents',
        () async {
      final subjectId = await documents.createSubject('Chemistry');
      expect(
        await documents.createSubject('Chemistry'),
        subjectId,
      );
      final documentId = await db
          .into(db.dbDocuments)
          .insert(
            DbDocumentsCompanion.insert(
              title: 'Cells',
              originalFileName: 'cells.pdf',
              format: 'pdf',
              sizeBytes: 10,
              pageCount: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              storedPath: '/tmp/cells.pdf',
            ),
          );
      await documents.assignSubject(documentId, subjectId);
      expect(
        (await documents.listDocuments()).first.subjectId,
        subjectId,
      );
      await documents.deleteSubject(subjectId);
      expect(await documents.listSubjects(), isEmpty);
      expect(
        (await documents.listDocuments()).first.subjectId,
        isNull,
      );
    });

    test('updateExtractedText persists an edit', () async {
      final documentId = await db
          .into(db.dbDocuments)
          .insert(
            DbDocumentsCompanion.insert(
              title: 'Cells',
              originalFileName: 'cells.pdf',
              format: 'pdf',
              sizeBytes: 10,
              pageCount: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              storedPath: '/tmp/cells.pdf',
            ),
          );
      await db
          .into(db.dbExtractedTexts)
          .insert(
            DbExtractedTextsCompanion.insert(
              documentId: Value(documentId),
              fullText: 'Old text.',
              charCount: 9,
            ),
          );
      await documents.updateExtractedText(documentId, 'Edited text.');
      final extracted = await documents.getExtractedDocument(documentId);
      expect(extracted!.fullText, 'Edited text.');
      expect(extracted.charCount, 12);
    });
  });
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/documents/data/document_repository_impl.dart';
import 'package:si_buddy/features/documents/domain/document_failures.dart';
import 'package:si_buddy/features/documents/domain/document_models.dart';

import 'pptx_fixture.dart';

void main() {
  late Directory tempRoot;
  late Directory sourceDir;
  late Directory storageRoot;
  late AppDatabase db;
  late DocumentRepositoryImpl repository;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('si_buddy_repo_test');
    sourceDir = await Directory('${tempRoot.path}/source').create();
    storageRoot = await Directory('${tempRoot.path}/storage').create();
    db = AppDatabase(NativeDatabase.memory());
    repository = DocumentRepositoryImpl(
      db: db,
      documentsDirectory: () async => storageRoot,
    );
  });

  tearDown(() async {
    await db.close();
    await tempRoot.delete(recursive: true);
  });

  Future<File> writeSource(String name, List<int> bytes) async {
    final file = File('${sourceDir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  List<int> deckBytes() {
    return buildPptx(
      slides: {
        1: [
          ['Cells are the basic unit of life.'],
        ],
        2: [
          ['The nucleus stores genetic information.'],
        ],
      },
    );
  }

  group('validatePickedFile', () {
    test('rejects an unsupported extension', () async {
      final file = await writeSource('notes.docx', deckBytes());
      await expectLater(
        repository.validatePickedFile(file.path),
        throwsA(isA<UnsupportedFormatException>()),
      );
    });

    test('rejects garbage bytes behind a .pptx name', () async {
      final file = await writeSource('broken.pptx', 'not a zip'.codeUnits);
      await expectLater(
        repository.validatePickedFile(file.path),
        throwsA(isA<CorruptedDocumentException>()),
      );
    });

    test('rejects an empty file', () async {
      final file = await writeSource('empty.pptx', const []);
      await expectLater(
        repository.validatePickedFile(file.path),
        throwsA(isA<CorruptedDocumentException>()),
      );
    });

    test('accepts a real pptx and probes its slide count', () async {
      final file = await writeSource('Biology Deck.pptx', deckBytes());
      final ref = await repository.validatePickedFile(file.path);
      expect(ref.format, DocumentFormat.pptx);
      expect(ref.name, 'Biology Deck.pptx');
      expect(ref.pageCount, 2);
      expect(ref.sizeBytes, greaterThan(0));
    });
  });

  group('extractText + library', () {
    test(
      'extracts, persists and manages a document end-to-end',
      () async {
        final source = await writeSource('Cell Biology.pptx', deckBytes());
        final fileRef = await repository.validatePickedFile(source.path);

        // The stage stream runs reading → extracting → preparing and
        // the final update carries the persisted document.
        final updates = await repository.extractText(fileRef).toList();
        final stages = <ExtractionStage>[];
        for (final update in updates) {
          if (stages.isEmpty || stages.last != update.stage) {
            stages.add(update.stage);
          }
        }
        expect(stages, [
          ExtractionStage.readingDocument,
          ExtractionStage.extractingText,
          ExtractionStage.preparingContent,
        ]);
        final result = updates.last.document;
        expect(result, isNotNull);
        expect(updates.last.fraction, 1);
        expect(result!.document.title, 'Cell Biology');
        expect(result.document.pageCount, 2);
        expect(result.sections, [
          'Cells are the basic unit of life.',
          'The nucleus stores genetic information.',
        ]);
        expect(result.hasText, isTrue);
        expect(
          result.fullText,
          'Cells are the basic unit of life.\n\n'
          'The nucleus stores genetic information.',
        );
        // The original file was copied into the library storage.
        expect(File(result.document.storedPath).existsSync(), isTrue);
        expect(result.document.storedPath, startsWith(storageRoot.path));

        // List + read back the persisted extraction.
        final listed = await repository.listDocuments();
        expect(listed, hasLength(1));
        expect(listed.single.id, result.document.id);
        final stored = await repository.getExtractedDocument(
          result.document.id,
        );
        expect(stored?.fullText, result.fullText);
        expect(stored?.sections, result.sections);
        expect(
          await repository.watchDocuments().first,
          hasLength(1),
        );
        expect(
          await repository.export(result.document.id),
          result.document.storedPath,
        );

        // Rename.
        await repository.rename(result.document.id, 'Cell Biology Ch. 4');
        expect(
          (await repository.listDocuments()).single.title,
          'Cell Biology Ch. 4',
        );

        // A second document imported into a folder; the first moves in.
        final second = await writeSource('Chemistry.pptx', deckBytes());
        final secondRef = await repository.validatePickedFile(second.path);
        final secondResult = (await repository
                .extractText(secondRef, folderName: 'Biology')
                .toList())
            .last
            .document!;
        expect(secondResult.document.folderId, isNotNull);
        await repository.moveToFolder(
          result.document.id,
          secondResult.document.folderId,
        );
        final both = await repository.listDocuments();
        expect(both, hasLength(2));
        expect(
          both.firstWhere((d) => d.id == result.document.id).folderId,
          secondResult.document.folderId,
        );

        // Delete removes the rows and the stored copy.
        final deletedPath = secondResult.document.storedPath;
        await repository.delete(secondResult.document.id);
        expect(await repository.listDocuments(), hasLength(1));
        expect(
          await repository.getExtractedDocument(secondResult.document.id),
          isNull,
        );
        expect(File(deletedPath).existsSync(), isFalse);
      },
    );

    test('a document with no text still extracts successfully', () async {
      final source = await writeSource(
        'Blank.pptx',
        buildPptx(slides: {1: []}),
      );
      final fileRef = await repository.validatePickedFile(source.path);
      final updates = await repository.extractText(fileRef).toList();
      final result = updates.last.document;
      expect(result, isNotNull);
      expect(result!.hasText, isFalse);
      expect(result.fullText, isEmpty);
      expect(await repository.listDocuments(), hasLength(1));
    });
  });
}

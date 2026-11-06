import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/document_failures.dart';
import '../domain/document_models.dart';
import '../domain/document_repository.dart';
import 'pdf_text_extractor.dart';
import 'pptx_text_extractor.dart';

/// [DocumentRepository] backed by file_picker, on-device extraction
/// (pdfrx_engine for PDFs, a custom parser for PPTX) and the drift
/// database. Original files are copied into the app documents
/// directory under `si_buddy/documents/` in a per-timestamp folder.
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({
    required this.db,
    Future<Directory> Function()? documentsDirectory,
    Future<Directory> Function()? temporaryDirectory,
    PdfTextExtractor? pdfExtractor,
    PptxTextExtractor? pptxExtractor,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _temporaryDirectory =
           temporaryDirectory ?? getTemporaryDirectory,
       _pdfExtractor = pdfExtractor ?? PdfTextExtractor(),
       _pptxExtractor = pptxExtractor ?? PptxTextExtractor();

  /// The database the library is persisted in.
  final AppDatabase db;
  final Future<Directory> Function() _documentsDirectory;
  final Future<Directory> Function() _temporaryDirectory;
  final PdfTextExtractor _pdfExtractor;
  final PptxTextExtractor _pptxExtractor;

  /// Temp files staged for cloud picks (see [validatePickedBytes]):
  /// removed once the library holds its own copy of the file.
  final _tempPickedPaths = <String>{};

  // -- Picking & validation -------------------------------------------------

  @override
  Future<FileRef?> pickFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'pptx'],
      dialogTitle: 'Choose a document',
    );
    if (picked == null) return null; // User cancelled.
    final path = picked.path;
    if (path != null) return validatePickedFile(path);
    // No local path: the file lives in the cloud (e.g. Google Drive)
    // and the picker only hands us a content URI. Read its bytes
    // through the picker and stage them in a temp file — otherwise
    // the pick silently did nothing.
    return validatePickedBytes(
      name: picked.name,
      readBytes: picked.readAsBytes,
    );
  }

  /// Validates a picked file that has no local path (a cloud file):
  /// reads its bytes and stages them in a temp file, then validates
  /// that file. Exposed so the bytes path can be tested without the
  /// platform picker.
  ///
  /// Throws [UnsupportedFormatException] or [CorruptedDocumentException].
  Future<FileRef> validatePickedBytes({
    required String name,
    required Future<Uint8List> Function() readBytes,
  }) async {
    late final Uint8List bytes;
    try {
      bytes = await readBytes();
    } on Object {
      throw CorruptedDocumentException(fileName: name);
    }
    final directory = Directory(
      p.join(
        (await _temporaryDirectory()).path,
        'si_buddy',
        'picked',
        '${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await directory.create(recursive: true);
    // The staged file keeps the picked name (in its own timestamped
    // folder, like the library copy) so the document title derived
    // from it stays clean.
    final stagedPath = p.join(directory.path, name);
    await File(stagedPath).writeAsBytes(bytes, flush: true);
    _tempPickedPaths.add(stagedPath);
    try {
      return await validatePickedFile(stagedPath);
    } catch (_) {
      // A failed pick leaves no staged file behind.
      _tempPickedPaths.remove(stagedPath);
      try {
        await File(stagedPath).delete();
      } on Object {
        // Ignore: the OS cleans its cache directory.
      }
      rethrow;
    }
  }

  /// Validates a picked file at [path] and builds its [FileRef]:
  /// supported extension, non-empty, and openable (which also probes
  /// the page/slide count). Exposed so validation can be tested and
  /// reused for files picked through other routes.
  ///
  /// Throws [UnsupportedFormatException] or [CorruptedDocumentException].
  Future<FileRef> validatePickedFile(String path) async {
    final name = p.basename(path);
    final format = DocumentFormat.fromExtension(p.extension(path).replaceFirst('.', ''));
    if (format == null) throw UnsupportedFormatException(fileName: name);

    final file = File(path);
    if (!file.existsSync()) {
      throw CorruptedDocumentException(fileName: name, reason: 'File not found.');
    }
    final sizeBytes = await file.length();
    if (sizeBytes == 0) {
      throw CorruptedDocumentException(fileName: name, reason: 'File is empty.');
    }

    final pageCount = switch (format) {
      DocumentFormat.pdf => await _pdfExtractor.pageCount(path),
      DocumentFormat.pptx => _pptxExtractor.slideCount(
        await file.readAsBytes(),
        fileName: name,
      ),
    };
    return FileRef(
      path: path,
      name: name,
      format: format,
      sizeBytes: sizeBytes,
      pageCount: pageCount,
    );
  }

  // -- Extraction -----------------------------------------------------------

  @override
  Stream<ExtractionUpdate> extractText(
    FileRef file, {
    String? title,
    String? folderName,
  }) {
    late final StreamController<ExtractionUpdate> controller;
    var cancelled = false;
    controller = StreamController<ExtractionUpdate>(
      onCancel: () => cancelled = true,
    );
    () async {
      try {
        await _runExtraction(
          file,
          title: title,
          folderName: folderName,
          emit: controller.add,
          isCancelled: () => cancelled,
        );
      } on DocumentFailure catch (failure) {
        if (!cancelled) controller.addError(failure);
      } on Object {
        if (!cancelled) {
          controller.addError(CorruptedDocumentException(fileName: file.name));
        }
      } finally {
        await controller.close();
      }
    }();
    return controller.stream;
  }

  Future<void> _runExtraction(
    FileRef file, {
    required String? title,
    required String? folderName,
    required void Function(ExtractionUpdate update) emit,
    required bool Function() isCancelled,
  }) async {
    // Stage 1 — Reading Document: count pages/slides, then copy the
    // file into the app's private storage.
    emit(
      const ExtractionUpdate(
        stage: ExtractionStage.readingDocument,
        fraction: 0,
      ),
    );
    final bytes = file.format == DocumentFormat.pptx
        ? await File(file.path).readAsBytes()
        : null;
    final totalPages =
        file.pageCount ??
        switch (file.format) {
          DocumentFormat.pdf => await _pdfExtractor.pageCount(file.path),
          DocumentFormat.pptx => _pptxExtractor.slideCount(
            bytes!,
            fileName: file.name,
          ),
        };
    final storedFile = await _copyIntoLibrary(file);
    await _discardStagedPick(file.path);
    if (isCancelled()) return;
    emit(
      ExtractionUpdate(
        stage: ExtractionStage.extractingText,
        fraction: 0.05,
        totalPages: totalPages,
      ),
    );

    // Stage 2 — Extracting Text: one section per page/slide. PDF
    // pages without a text layer are read with OCR; the extractor
    // reports those pages so the progress line can say so.
    final sections = switch (file.format) {
      DocumentFormat.pdf => await _pdfExtractor.extractPageTexts(
        file.path,
        onPageStart: (index, total) => emit(
          ExtractionUpdate(
            stage: ExtractionStage.extractingText,
            currentPage: index + 1,
            totalPages: total,
            fraction: 0.05 + 0.85 * (total == 0 ? 0 : index / total),
          ),
        ),
        onOcrPageStart: (index, total) => emit(
          ExtractionUpdate(
            stage: ExtractionStage.extractingText,
            currentPage: index + 1,
            totalPages: total,
            fraction: 0.05 + 0.85 * (total == 0 ? 0 : index / total),
            ocrActive: true,
          ),
        ),
        isCancelled: isCancelled,
      ),
      DocumentFormat.pptx => _pptxExtractor.extractSlideTexts(
        bytes!,
        fileName: file.name,
        onSlideStart: (index, total) => emit(
          ExtractionUpdate(
            stage: ExtractionStage.extractingText,
            currentPage: index + 1,
            totalPages: total,
            fraction: 0.05 + 0.85 * (total == 0 ? 0 : index / total),
          ),
        ),
        isCancelled: isCancelled,
      ),
    };
    if (isCancelled()) return;

    // Stage 3 — Preparing Content: persist document + extracted text.
    emit(
      ExtractionUpdate(
        stage: ExtractionStage.preparingContent,
        currentPage: totalPages,
        totalPages: totalPages,
        fraction: 0.95,
      ),
    );
    final fullText = sections.join('\n\n');
    final now = DateTime.now();
    final documentTitle = _resolveTitle(file, title);
    final extracted = await db.transaction(() async {
      final folderId = folderName == null
          ? null
          : await _findOrCreateFolder(folderName);
      final documentId = await db
          .into(db.dbDocuments)
          .insert(
            DbDocumentsCompanion.insert(
              title: documentTitle,
              originalFileName: file.name,
              format: file.format.name,
              sizeBytes: file.sizeBytes,
              pageCount: totalPages,
              folderId: Value(folderId),
              createdAt: now,
              updatedAt: now,
              storedPath: storedFile.path,
            ),
          );
      await db
          .into(db.dbExtractedTexts)
          .insert(
            DbExtractedTextsCompanion.insert(
              documentId: Value(documentId),
              fullText: fullText,
              charCount: fullText.length,
            ),
          );
      final document = Document(
        id: documentId,
        title: documentTitle,
        originalFileName: file.name,
        format: file.format,
        sizeBytes: file.sizeBytes,
        pageCount: totalPages,
        folderId: folderId,
        createdAt: now,
        updatedAt: now,
        storedPath: storedFile.path,
      );
      return ExtractedDocument(
        document: document,
        fullText: fullText,
        sections: sections,
        charCount: fullText.length,
      );
    });
    emit(
      ExtractionUpdate(
        stage: ExtractionStage.preparingContent,
        currentPage: totalPages,
        totalPages: totalPages,
        fraction: 1,
        document: extracted,
      ),
    );
  }

  /// Removes a staged cloud pick once the library holds its own copy.
  /// Best-effort: a leftover staged file is just a cache file.
  Future<void> _discardStagedPick(String path) async {
    if (!_tempPickedPaths.remove(path)) return;
    try {
      await File(path).delete();
    } on Object {
      // Ignore: the OS cleans its cache directory.
    }
  }

  /// Copies the picked file into the app documents directory, under
  /// `si_buddy/documents/<timestamp>/<file name>`, and returns the copy.
  Future<File> _copyIntoLibrary(FileRef file) async {
    try {
      final root = await _documentsDirectory();
      final directory = Directory(
        p.join(
          root.path,
          'si_buddy',
          'documents',
          '${DateTime.now().microsecondsSinceEpoch}',
        ),
      );
      await directory.create(recursive: true);
      return await File(file.path).copy(p.join(directory.path, file.name));
    } on FileSystemException {
      throw InsufficientStorageException(fileName: file.name);
    }
  }

  String _resolveTitle(FileRef file, String? title) {
    final candidate = (title ?? file.name).trim();
    final withoutExtension = candidate.toLowerCase().endsWith(
          '.${file.format.extension}',
        )
        ? candidate.substring(
            0,
            candidate.length - file.format.extension.length - 1,
          )
        : candidate;
    return withoutExtension.isEmpty ? file.name : withoutExtension;
  }

  Future<int> _findOrCreateFolder(String name) async {
    final existing = await (db.select(
      db.dbFolders,
    )..where((row) => row.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return db.into(db.dbFolders).insert(DbFoldersCompanion.insert(name: name));
  }

  // -- Library --------------------------------------------------------------

  @override
  Future<List<Document>> listDocuments() async {
    final rows = await _documentsQuery().get();
    return [for (final row in rows) _toDocument(row)];
  }

  @override
  Stream<List<Document>> watchDocuments() {
    return _documentsQuery().watch().map(
      (rows) => [for (final row in rows) _toDocument(row)],
    );
  }

  SimpleSelectStatement<$DbDocumentsTable, DbDocument> _documentsQuery() {
    return db.select(db.dbDocuments)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
  }

  @override
  Future<ExtractedDocument?> getExtractedDocument(int documentId) async {
    final row = await (db.select(
      db.dbDocuments,
    )..where((doc) => doc.id.equals(documentId))).getSingleOrNull();
    if (row == null) return null;
    final textRow = await (db.select(
      db.dbExtractedTexts,
    )..where((text) => text.documentId.equals(documentId))).getSingleOrNull();
    if (textRow == null) return null;
    return ExtractedDocument(
      document: _toDocument(row),
      fullText: textRow.fullText,
      // Sections were joined with blank lines when persisted.
      sections: textRow.fullText.isEmpty
          ? const []
          : textRow.fullText.split('\n\n'),
      charCount: textRow.charCount,
    );
  }

  @override
  Future<void> rename(int documentId, String newTitle) async {
    await (db.update(db.dbDocuments)
          ..where((row) => row.id.equals(documentId)))
        .write(
          DbDocumentsCompanion(
            title: Value(newTitle),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> updateExtractedText(int documentId, String fullText) async {
    final trimmed = fullText.trim();
    await db
        .into(db.dbExtractedTexts)
        .insert(
          DbExtractedTextsCompanion.insert(
            documentId: Value(documentId),
            fullText: fullText,
            charCount: trimmed.length,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> delete(int documentId) async {
    final row = await (db.select(
      db.dbDocuments,
    )..where((doc) => doc.id.equals(documentId))).getSingleOrNull();
    await (db.delete(
      db.dbDocuments,
    )..where((doc) => doc.id.equals(documentId))).go();
    // The stored copy lives in its own per-document folder.
    if (row != null) {
      final directory = File(row.storedPath).parent;
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  }

  @override
  Future<void> moveToFolder(int documentId, int? folderId) async {
    await (db.update(db.dbDocuments)
          ..where((row) => row.id.equals(documentId)))
        .write(
          DbDocumentsCompanion(
            folderId: Value(folderId),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> assignSubject(int documentId, int? subjectId) async {
    await (db.update(db.dbDocuments)
          ..where((row) => row.id.equals(documentId)))
        .write(
          DbDocumentsCompanion(
            subjectId: Value(subjectId),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // -- Folders and subjects -------------------------------------------

  @override
  Future<List<DocumentFolder>> listFolders() async {
    final rows = await (db.select(db.dbFolders)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    return [
      for (final row in rows)
        DocumentFolder(id: row.id, name: row.name),
    ];
  }

  @override
  Stream<List<DocumentFolder>> watchFolders() {
    final query = db.select(db.dbFolders)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          DocumentFolder(id: row.id, name: row.name),
      ],
    );
  }

  @override
  Future<int> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Folder name must not be empty.');
    }
    return _findOrCreateFolder(trimmed);
  }

  @override
  Future<void> renameFolder(int folderId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Folder name must not be empty.');
    }
    final clash = await (db.select(db.dbFolders)
          ..where(
            (row) => row.name.equals(trimmed) & row.id.isNotValue(folderId),
          ))
        .getSingleOrNull();
    if (clash != null) {
      throw StateError('A folder named "$trimmed" already exists.');
    }
    await (db.update(db.dbFolders)
          ..where((row) => row.id.equals(folderId)))
        .write(DbFoldersCompanion(name: Value(trimmed)));
  }

  @override
  Future<void> deleteFolder(int folderId) async {
    // Documents in the folder are NOT deleted: their folder id is
    // cleared by the foreign key (onDelete: setNull).
    await (db.delete(
      db.dbFolders,
    )..where((row) => row.id.equals(folderId))).go();
  }

  @override
  Future<List<DocumentSubject>> listSubjects() async {
    final rows = await (db.select(db.dbSubjects)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    return [
      for (final row in rows)
        DocumentSubject(id: row.id, name: row.name),
    ];
  }

  @override
  Stream<List<DocumentSubject>> watchSubjects() {
    final query = db.select(db.dbSubjects)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          DocumentSubject(id: row.id, name: row.name),
      ],
    );
  }

  @override
  Future<int> createSubject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Subject name must not be empty.');
    }
    final existing = await (db.select(
      db.dbSubjects,
    )..where((row) => row.name.equals(trimmed))).getSingleOrNull();
    if (existing != null) return existing.id;
    return db
        .into(db.dbSubjects)
        .insert(
          DbSubjectsCompanion.insert(name: trimmed, createdAt: DateTime.now()),
        );
  }

  @override
  Future<void> renameSubject(int subjectId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Subject name must not be empty.');
    }
    final clash = await (db.select(db.dbSubjects)
          ..where(
            (row) => row.name.equals(trimmed) & row.id.isNotValue(subjectId),
          ))
        .getSingleOrNull();
    if (clash != null) {
      throw StateError('A subject named "$trimmed" already exists.');
    }
    await (db.update(db.dbSubjects)
          ..where((row) => row.id.equals(subjectId)))
        .write(DbSubjectsCompanion(name: Value(trimmed)));
  }

  @override
  Future<void> deleteSubject(int subjectId) async {
    // Documents with this subject are NOT deleted: their subject id
    // is cleared by the foreign key (onDelete: setNull) and they
    // read as Unassigned.
    await (db.delete(
      db.dbSubjects,
    )..where((row) => row.id.equals(subjectId))).go();
  }

  @override
  Future<String> export(int documentId) async {
    final row = await (db.select(
      db.dbDocuments,
    )..where((doc) => doc.id.equals(documentId))).getSingleOrNull();
    if (row == null) {
      throw StateError('Document $documentId does not exist.');
    }
    return row.storedPath;
  }

  Document _toDocument(DbDocument row) {
    return Document(
      id: row.id,
      title: row.title,
      originalFileName: row.originalFileName,
      format: DocumentFormat.values.byName(row.format),
      sizeBytes: row.sizeBytes,
      pageCount: row.pageCount,
      folderId: row.folderId,
      subjectId: row.subjectId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      storedPath: row.storedPath,
    );
  }
}

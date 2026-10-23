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
    PdfTextExtractor? pdfExtractor,
    PptxTextExtractor? pptxExtractor,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _pdfExtractor = pdfExtractor ?? PdfTextExtractor(),
       _pptxExtractor = pptxExtractor ?? PptxTextExtractor();

  /// The database the library is persisted in.
  final AppDatabase db;
  final Future<Directory> Function() _documentsDirectory;
  final PdfTextExtractor _pdfExtractor;
  final PptxTextExtractor _pptxExtractor;

  // -- Picking & validation -------------------------------------------------

  @override
  Future<FileRef?> pickFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'pptx'],
      dialogTitle: 'Choose a document',
    );
    final path = picked?.path;
    if (picked == null || path == null) return null; // User cancelled.
    return validatePickedFile(path);
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
    if (isCancelled()) return;
    emit(
      ExtractionUpdate(
        stage: ExtractionStage.extractingText,
        fraction: 0.05,
        totalPages: totalPages,
      ),
    );

    // Stage 2 — Extracting Text: one section per page/slide.
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
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      storedPath: row.storedPath,
    );
  }
}

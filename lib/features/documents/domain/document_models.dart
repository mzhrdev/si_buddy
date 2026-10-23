// Domain entities for the documents feature: imported files, their
// library records and the text extracted from them.
//
// These are plain Dart classes — the data layer maps them to and from
// drift rows, and the presentation layer only ever sees these types.

/// A document format the app can import.
enum DocumentFormat {
  pdf('PDF', 'pdf'),
  pptx('PPTX', 'pptx');

  const DocumentFormat(this.label, this.extension);

  /// Short format label used in metadata lines, e.g. `PDF`.
  final String label;

  /// Lowercase file extension without the dot, e.g. `pdf`.
  final String extension;

  /// The countable unit of the format: PDFs have pages, decks have slides.
  String get unitLabel => this == DocumentFormat.pdf ? 'pages' : 'slides';

  /// The format for a file extension, or null when unsupported.
  static DocumentFormat? fromExtension(String extension) {
    return switch (extension.toLowerCase()) {
      'pdf' => DocumentFormat.pdf,
      'pptx' => DocumentFormat.pptx,
      _ => null,
    };
  }
}

/// Formats a byte count the way the designs do: `840 KB`, `2.4 MB`.
String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
  return '$bytes B';
}

/// A file chosen by the user, validated but not yet imported.
///
/// Produced by `DocumentRepository.pickFile` (or by validating a picked
/// path) and consumed by `DocumentRepository.extractText`.
class FileRef {
  const FileRef({
    required this.path,
    required this.name,
    required this.format,
    required this.sizeBytes,
    this.pageCount,
  });

  /// Absolute path of the picked file on the device.
  final String path;

  /// File name including the extension, e.g. `Cell Biology - Chapter 4.pdf`.
  final String name;

  final DocumentFormat format;

  /// Size of the file in bytes (always > 0 for a validated file).
  final int sizeBytes;

  /// Pages (PDF) or slides (PPTX), probed during validation.
  final int? pageCount;

  /// The design-style size label, e.g. `2.4 MB`.
  String get sizeLabel => formatFileSize(sizeBytes);
}

/// A named folder (subject) documents can be organised into.
class DocumentFolder {
  const DocumentFolder({required this.id, required this.name});

  final int id;
  final String name;
}

/// A document saved in the local library.
class Document {
  const Document({
    required this.id,
    required this.title,
    required this.originalFileName,
    required this.format,
    required this.sizeBytes,
    required this.pageCount,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.storedPath,
  });

  final int id;

  /// Display title (the file name without its extension, unless renamed).
  final String title;

  /// The file name the document was imported from, extension included.
  final String originalFileName;

  final DocumentFormat format;
  final int sizeBytes;

  /// Pages for a PDF, slides for a PPTX.
  final int pageCount;

  /// The folder this document belongs to, or null when unfiled.
  final int? folderId;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Absolute path of the app's private copy of the original file.
  final String storedPath;

  Document copyWith({String? title, int? folderId, DateTime? updatedAt}) {
    return Document(
      id: id,
      title: title ?? this.title,
      originalFileName: originalFileName,
      format: format,
      sizeBytes: sizeBytes,
      pageCount: pageCount,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storedPath: storedPath,
    );
  }
}

/// The text extracted from a [Document], ready for review and (later)
/// AI generation.
class ExtractedDocument {
  const ExtractedDocument({
    required this.document,
    required this.fullText,
    required this.sections,
    required this.charCount,
  });

  /// The library record this text belongs to.
  final Document document;

  /// All extracted text, sections joined by blank lines.
  final String fullText;

  /// Text per page (PDF) or per slide (PPTX), in order.
  final List<String> sections;

  /// Character count of [fullText].
  final int charCount;

  /// False when the document yielded no readable text at all (e.g. a
  /// scanned, image-only PDF). Extraction still succeeds in that case;
  /// the flag exists so later phases (OCR, AI generation) can react.
  bool get hasText => fullText.trim().isNotEmpty;
}

/// One stage of the extraction pipeline, mirroring the staged checklist
/// rendered by the extraction processing screen. The [label]s are the
/// screen's exact stage titles.
enum ExtractionStage {
  readingDocument('Reading Document'),
  extractingText('Extracting Text'),
  preparingContent('Preparing Content');

  const ExtractionStage(this.label);

  /// The stage title as shown on the processing screen.
  final String label;
}

/// A progress event emitted while extracting a document.
///
/// The stream returned by `DocumentRepository.extractText` emits these
/// in stage order. Intermediate events carry progress only; the final
/// event (stage [ExtractionStage.preparingContent], fraction 1.0)
/// additionally carries the persisted result in [document]. Failures
/// are delivered on the stream's error channel as typed
/// `DocumentFailure`s — never as events.
class ExtractionUpdate {
  const ExtractionUpdate({
    required this.stage,
    required this.fraction,
    this.currentPage = 0,
    this.totalPages = 0,
    this.document,
  });

  /// The stage currently in progress.
  final ExtractionStage stage;

  /// Overall progress, 0.0–1.0.
  final double fraction;

  /// The page/slide being processed (1-based) during extraction.
  final int currentPage;

  /// Total pages/slides, once known.
  final int totalPages;

  /// The finished extraction; non-null only on the final event.
  final ExtractedDocument? document;
}

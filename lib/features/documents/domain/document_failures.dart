// Typed failures thrown by the documents data layer.
//
// Each failure maps to one of the already-designed error screens, so
// the presentation layer can route on the type: unsupported file,
// corrupted document, insufficient storage, insufficient text.

/// Base type for all document failures.
abstract class DocumentFailure implements Exception {
  const DocumentFailure(this.fileName);

  /// The file the failure relates to, when known.
  final String? fileName;

  /// User-facing explanation of what went wrong.
  String get message;

  @override
  String toString() => message;
}

/// The picked file's format is not one the app can import
/// (anything other than PDF / PPTX).
class UnsupportedFormatException extends DocumentFailure {
  const UnsupportedFormatException({required String fileName})
    : super(fileName);

  @override
  String get message =>
      '“$fileName” is not a supported file type. Choose a PDF or PPTX file.';
}

/// The file could not be opened or parsed: a corrupt PDF, a PPTX whose
/// contents are not a real presentation, an empty file, and so on.
class CorruptedDocumentException extends DocumentFailure {
  const CorruptedDocumentException({required String fileName, this.reason})
    : super(fileName);

  /// Optional technical detail for logs; not shown to the user.
  final String? reason;

  @override
  String get message =>
      '“$fileName” could not be opened. The file may be damaged.';
}

/// There was not enough free storage to save the document into the
/// app's library.
class InsufficientStorageException extends DocumentFailure {
  const InsufficientStorageException({required String fileName})
    : super(fileName);

  @override
  String get message =>
      'Not enough storage space to save “$fileName” on this device.';
}

/// The document yielded too little text to be useful. Extraction itself
/// does not throw this (an empty result is a valid extraction); it is
/// reserved for AI generation, which needs a minimum amount of text.
class InsufficientTextException extends DocumentFailure {
  const InsufficientTextException({String? fileName, this.charCount = 0})
    : super(fileName);

  /// How many characters of text were available.
  final int charCount;

  @override
  String get message =>
      'There is not enough readable text in this document yet.';
}

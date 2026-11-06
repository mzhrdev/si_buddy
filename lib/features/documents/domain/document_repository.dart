import 'document_models.dart';

/// The documents feature's gateway to file picking, text extraction
/// and the local library.
///
/// Implementations throw the typed failures from
/// `document_failures.dart`; the UI routes to the matching designed
/// error screen based on the failure type.
abstract class DocumentRepository {
  /// Opens the platform file picker restricted to PDF and PPTX files.
  ///
  /// Returns a validated [FileRef], or null when the user cancels the
  /// picker. Throws [UnsupportedFormatException] for other file types
  /// and [CorruptedDocumentException] for files that fail to open
  /// during the validation probe.
  Future<FileRef?> pickFile();

  /// Imports [file]: copies it into the app's private storage,
  /// extracts its text and persists both the document and the text.
  ///
  /// Progress is emitted as [ExtractionUpdate]s in stage order
  /// (reading → extracting → preparing). The final update carries the
  /// persisted [ExtractedDocument]; see [ExtractionUpdate] for the
  /// contract. [title] overrides the document title (defaults to the
  /// file name without its extension) and [folderName] files the
  /// document into a folder with that name, creating it if needed.
  ///
  /// Cancelling the returned stream's subscription aborts the job;
  /// nothing is persisted in that case. A document that yields no text
  /// at all still completes successfully — its [ExtractedDocument] is
  /// flagged via `hasText == false` rather than failing.
  Stream<ExtractionUpdate> extractText(
    FileRef file, {
    String? title,
    String? folderName,
  });

  /// All documents in the library, most recently updated first.
  Future<List<Document>> listDocuments();

  /// The same list as [listDocuments], streamed as it changes.
  Stream<List<Document>> watchDocuments();

  /// The extracted text for a document, or null when not found.
  Future<ExtractedDocument?> getExtractedDocument(int documentId);

  /// Renames a library document.
  Future<void> rename(int documentId, String newTitle);

  /// Replaces a document's saved extracted text (the review screen's
  /// edit flow). The edit is persisted locally and survives
  /// navigating away and reopening the document.
  Future<void> updateExtractedText(int documentId, String fullText);

  /// Deletes a library document: its database rows and its stored
  /// file copy. Its decks, extracted text and study data are removed
  /// with it via foreign keys — no orphaned study sets remain.
  Future<void> delete(int documentId);

  /// Moves a document into a folder (null = unfiled).
  Future<void> moveToFolder(int documentId, int? folderId);

  /// Assigns a subject category to a document (null = Unassigned).
  Future<void> assignSubject(int documentId, int? subjectId);

  /// Returns the path of the document's stored file copy, suitable for
  /// sharing or opening with an external viewer.
  Future<String> export(int documentId);

  // -- Folders and subjects (organization) -------------------------

  /// All folders, by name.
  Future<List<DocumentFolder>> listFolders();

  /// The same list, streamed as it changes.
  Stream<List<DocumentFolder>> watchFolders();

  /// Creates a folder and returns its id. Returns the existing
  /// folder's id when a folder with that name already exists.
  Future<int> createFolder(String name);

  /// Renames a folder. Throws [StateError] when another folder
  /// already has the new name.
  Future<void> renameFolder(int folderId, String newName);

  /// Deletes a folder. Its documents are NOT deleted — they become
  /// unfiled (their folder id is cleared by the foreign key).
  Future<void> deleteFolder(int folderId);

  /// All subjects, by name.
  Future<List<DocumentSubject>> listSubjects();

  /// The same list, streamed as it changes.
  Stream<List<DocumentSubject>> watchSubjects();

  /// Creates a subject and returns its id. Returns the existing
  /// subject's id when a subject with that name already exists.
  Future<int> createSubject(String name);

  /// Renames a subject. Throws [StateError] when another subject
  /// already has the new name.
  Future<void> renameSubject(int subjectId, String newName);

  /// Deletes a subject. Documents assigned to it become Unassigned
  /// (their subject id is cleared by the foreign key).
  Future<void> deleteSubject(int subjectId);
}

/// The shape the library cards render. Items are built from saved
/// document records by `documentToLibraryItem` in the documents
/// providers — there is no sample list here any more.
class LibraryDocumentItem {
  const LibraryDocumentItem({
    required this.format,
    required this.title,
    required this.date,
    required this.studySets,
    required this.subject,
  });

  final String format;
  final String title;
  final String date;
  final String studySets;
  final String subject;

  /// Meta line used by the list cards, e.g. "PDF · 16 Oct 2026 · 2 study sets".
  String get listMeta => '$format · $date · $studySets';
}

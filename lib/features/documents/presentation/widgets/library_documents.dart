/// Mock document data mirroring the Figma library frames (the real data
/// layer comes later). Shared by the list and grid library screens.
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

/// The four documents shown in the Figma library frames.
const libraryDocuments = <LibraryDocumentItem>[
  LibraryDocumentItem(
    format: 'PDF',
    title: 'Cell Biology - Chapter 4.pdf',
    date: '16 Oct 2026',
    studySets: '2 study sets',
    subject: 'Biology · Semester 1',
  ),
  LibraryDocumentItem(
    format: 'PPTX',
    title: 'Organic Chemistry.pptx',
    date: '15 Oct 2026',
    studySets: '1 study set',
    subject: 'Chemistry · Semester 1',
  ),
  LibraryDocumentItem(
    format: 'DOCX',
    title: 'Research Methods.docx',
    date: '12 Oct 2026',
    studySets: '0 study sets',
    subject: 'Research · Coursework',
  ),
  LibraryDocumentItem(
    format: 'PDF',
    title: 'Cell Membranes.pdf',
    date: '10 Oct 2026',
    studySets: '1 study set',
    subject: 'Biology · Semester 1',
  ),
];

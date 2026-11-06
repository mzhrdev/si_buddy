import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/document_models.dart';
import '../../../study/presentation/providers/study_providers.dart';
import 'documents_providers.dart';

/// The library's folders, streamed as they change — for the
/// Organize screen and the Folders & subjects row.
final libraryFoldersProvider = StreamProvider<List<DocumentFolder>>((ref) {
  return ref.watch(documentRepositoryProvider).watchFolders();
});

/// The library's subjects, streamed as they change — for the
/// Subject filter chips and the Organize screen.
final librarySubjectsProvider = StreamProvider<List<DocumentSubject>>((ref) {
  return ref.watch(documentRepositoryProvider).watchSubjects();
});

// ---------------------------------------------------------------------------
// Library filters & sorting (Phase 4): the state the filters &
// sorting screen edits and the list/grid screens render. Filters
// actually apply here — the screens read [filteredDocumentsProvider],
// never the raw library stream.
// ---------------------------------------------------------------------------

/// How the library list is ordered.
enum LibrarySort {
  newestFirst('Newest first'),
  oldestFirst('Oldest first'),
  filenameAZ('Filename A–Z'),
  mostStudySets('Most study sets');

  const LibrarySort(this.label);

  final String label;
}

/// Which import-date window the library shows.
enum LibraryDateFilter {
  anyTime('Any time'),
  last7Days('Last 7 days'),
  last30Days('Last 30 days'),
  customRange('Custom range');

  const LibraryDateFilter(this.label);

  final String label;
}

/// The library's active filters and sort. Empty sets mean "all":
/// no file-type restriction, no subject restriction.
class LibraryFilterState {
  const LibraryFilterState({
    this.sort = LibrarySort.newestFirst,
    this.fileTypes = const {},
    this.subjectIds = const {},
    this.dateFilter = LibraryDateFilter.anyTime,
    this.customStart,
    this.customEnd,
  });

  final LibrarySort sort;

  /// File formats to show; empty means every format.
  final Set<DocumentFormat> fileTypes;

  /// Subject ids to show, with `null` meaning Unassigned; empty
  /// means every subject.
  final Set<int?> subjectIds;
  final LibraryDateFilter dateFilter;

  /// Custom-range window (inclusive), used only when [dateFilter]
  /// is [LibraryDateFilter.customRange].
  final DateTime? customStart;
  final DateTime? customEnd;

  static const defaults = LibraryFilterState();

  bool get isDefault =>
      sort == LibrarySort.newestFirst &&
      fileTypes.isEmpty &&
      subjectIds.isEmpty &&
      dateFilter == LibraryDateFilter.anyTime;

  /// How many filter groups are active (sort never counts): the
  /// badge on the library's Filters button.
  int get activeFilterCount {
    var count = 0;
    if (fileTypes.isNotEmpty) count++;
    if (subjectIds.isNotEmpty) count++;
    if (dateFilter != LibraryDateFilter.anyTime) count++;
    return count;
  }

  LibraryFilterState copyWith({
    LibrarySort? sort,
    Set<DocumentFormat>? fileTypes,
    Set<int?>? subjectIds,
    LibraryDateFilter? dateFilter,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomRange = false,
  }) {
    return LibraryFilterState(
      sort: sort ?? this.sort,
      fileTypes: fileTypes ?? this.fileTypes,
      subjectIds: subjectIds ?? this.subjectIds,
      dateFilter: dateFilter ?? this.dateFilter,
      customStart: clearCustomRange ? null : customStart ?? this.customStart,
      customEnd: clearCustomRange ? null : customEnd ?? this.customEnd,
    );
  }

  /// Whether [document] passes the filters (sort is applied
  /// separately). [deckCounts] maps document id to its study-set
  /// count; it is only needed for the Most Study Sets sort.
  bool matches(Document document) {
    if (fileTypes.isNotEmpty && !fileTypes.contains(document.format)) {
      return false;
    }
    if (subjectIds.isNotEmpty && !subjectIds.contains(document.subjectId)) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (dateFilter) {
      case LibraryDateFilter.anyTime:
        break;
      case LibraryDateFilter.last7Days:
        if (document.createdAt.isBefore(
          today.subtract(const Duration(days: 7)),
        )) {
          return false;
        }
      case LibraryDateFilter.last30Days:
        if (document.createdAt.isBefore(
          today.subtract(const Duration(days: 30)),
        )) {
          return false;
        }
      case LibraryDateFilter.customRange:
        if (customStart != null &&
            document.createdAt.isBefore(_dayStart(customStart!))) {
          return false;
        }
        if (customEnd != null &&
            document.createdAt.isAfter(_dayEnd(customEnd!))) {
          return false;
        }
    }
    return true;
  }

  static DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _dayEnd(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Orders two documents per [sort]; [deckCounts] maps document id
  /// to its study-set count.
  int compare(Document a, Document b, Map<int, int> deckCounts) {
    switch (sort) {
      case LibrarySort.newestFirst:
        return b.createdAt.compareTo(a.createdAt);
      case LibrarySort.oldestFirst:
        return a.createdAt.compareTo(b.createdAt);
      case LibrarySort.filenameAZ:
        return documentDisplayName(
          a,
        ).toLowerCase().compareTo(documentDisplayName(b).toLowerCase());
      case LibrarySort.mostStudySets:
        final bySets = (deckCounts[b.id] ?? 0).compareTo(deckCounts[a.id] ?? 0);
        if (bySets != 0) return bySets;
        return b.createdAt.compareTo(a.createdAt);
    }
  }

  /// Applies the filters and sort to [documents]; the shared
  /// implementation the provider and the filters screen's live
  /// match count both use.
  List<Document> apply(List<Document> documents, Map<int, int> deckCounts) {
    final filtered = documents.where(matches).toList();
    filtered.sort((a, b) => compare(a, b, deckCounts));
    return filtered;
  }
}

class LibraryFilterNotifier extends Notifier<LibraryFilterState> {
  @override
  LibraryFilterState build() => LibraryFilterState.defaults;

  void set(LibraryFilterState next) => state = next;

  void reset() => state = LibraryFilterState.defaults;
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilterState>(
      LibraryFilterNotifier.new,
    );

/// The library documents after the active filters and sort, in
/// display order. List and grid both read this, so they always
/// agree.
final filteredDocumentsProvider = Provider<List<Document>>((ref) {
  final documents = ref.watch(documentsStreamProvider).value ?? const [];
  final counts = ref.watch(deckCountsByDocumentProvider).value ?? const {};
  final filter = ref.watch(libraryFilterProvider);
  return filter.apply(documents, counts);
});

// ---------------------------------------------------------------------------
// Inline library search (Phase 4): the query lives in a provider so
// it survives the list/grid toggle, and the results combine the
// library documents (by name) with persisted study content.
// ---------------------------------------------------------------------------

/// The library search query, shared by the list and grid screens.
/// A [Notifier] (Riverpod 3 has no StateProvider any more).
class LibrarySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final librarySearchQueryProvider =
    NotifierProvider<LibrarySearchQueryNotifier, String>(
      LibrarySearchQueryNotifier.new,
    );

/// One inline-search result, tagged by what it is.
enum LibrarySearchKind { document, flashcard, quiz }

class LibrarySearchResult {
  const LibrarySearchResult({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.documentId,
    this.deckId,
  });

  final LibrarySearchKind kind;

  /// Document name, or the deck's title for card/quiz matches.
  final String title;

  /// Document meta line, or the matching card/question text.
  final String subtitle;
  final int? documentId;
  final int? deckId;

  String get tagLabel => switch (kind) {
    LibrarySearchKind.document => 'Document',
    LibrarySearchKind.flashcard => 'Flashcard',
    LibrarySearchKind.quiz => 'Quiz',
  };
}

/// Inline-search results for the current query: documents by name
/// first, then persisted flashcards and quiz questions by their
/// text. Empty when the query is empty.
final librarySearchResultsProvider = FutureProvider<List<LibrarySearchResult>>((
  ref,
) async {
  final query = ref.watch(librarySearchQueryProvider).trim();
  if (query.isEmpty) return const [];
  final needle = query.toLowerCase();
  final documents = ref.watch(documentsStreamProvider).value ?? const [];
  final results = <LibrarySearchResult>[
    for (final document in documents)
      if (documentDisplayName(document).toLowerCase().contains(needle) ||
          document.originalFileName.toLowerCase().contains(needle))
        LibrarySearchResult(
          kind: LibrarySearchKind.document,
          title: documentDisplayName(document),
          subtitle:
              '${document.format.label} · ${document.pageCount} ${document.format.unitLabel} · ${formatLibraryDate(document.createdAt)}',
          documentId: document.id,
        ),
  ];
  final matches = await ref
      .read(studyRepositoryProvider)
      .searchStudyContent(query);
  for (final match in matches) {
    results.add(
      LibrarySearchResult(
        kind: match.isQuiz
            ? LibrarySearchKind.quiz
            : LibrarySearchKind.flashcard,
        title: match.deck.title,
        subtitle: match.snippet,
        deckId: match.deck.id,
      ),
    );
  }
  return results;
});

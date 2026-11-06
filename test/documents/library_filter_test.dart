import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/documents/domain/document_models.dart';
import 'package:si_buddy/features/documents/presentation/providers/library_providers.dart';

Document _doc({
  required int id,
  required String title,
  DocumentFormat format = DocumentFormat.pdf,
  int? subjectId,
  required DateTime createdAt,
}) {
  return Document(
    id: id,
    title: title,
    originalFileName: '$title.${format.extension}',
    format: format,
    sizeBytes: 1024,
    pageCount: 3,
    folderId: null,
    subjectId: subjectId,
    createdAt: createdAt,
    updatedAt: createdAt,
    storedPath: '/tmp/$title.${format.extension}',
  );
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final docs = [
    _doc(id: 1, title: 'Cells', createdAt: today),
    _doc(
      id: 2,
      title: 'algebra',
      format: DocumentFormat.pptx,
      subjectId: 7,
      createdAt: today.subtract(const Duration(days: 3)),
    ),
    _doc(
      id: 3,
      title: 'Zoology',
      subjectId: 7,
      createdAt: today.subtract(const Duration(days: 20)),
    ),
    _doc(
      id: 4,
      title: 'Ancient history',
      createdAt: today.subtract(const Duration(days: 60)),
    ),
  ];
  const counts = {1: 2, 2: 5, 3: 5, 4: 0};

  test('defaults show everything, newest first', () {
    final result = LibraryFilterState.defaults.apply(docs, counts);
    expect(result.map((d) => d.id).toList(), [1, 2, 3, 4]);
    expect(LibraryFilterState.defaults.isDefault, isTrue);
    expect(LibraryFilterState.defaults.activeFilterCount, 0);
  });

  test('file-type filter keeps only the chosen format', () {
    final state = LibraryFilterState.defaults.copyWith(
      fileTypes: {DocumentFormat.pptx},
    );
    expect(state.apply(docs, counts).map((d) => d.id).toList(), [2]);
    expect(state.activeFilterCount, 1);
  });

  test('subject filter includes Unassigned (null) and named subjects', () {
    final unassigned = LibraryFilterState.defaults.copyWith(subjectIds: {null});
    expect(unassigned.apply(docs, counts).map((d) => d.id).toList(), [1, 4]);

    final named = LibraryFilterState.defaults.copyWith(subjectIds: {7});
    expect(named.apply(docs, counts).map((d) => d.id).toList(), [2, 3]);
  });

  test('last 7 and last 30 days windows use the import date', () {
    final week = LibraryFilterState.defaults.copyWith(
      dateFilter: LibraryDateFilter.last7Days,
    );
    expect(week.apply(docs, counts).map((d) => d.id).toList(), [1, 2]);

    final month = LibraryFilterState.defaults.copyWith(
      dateFilter: LibraryDateFilter.last30Days,
    );
    expect(month.apply(docs, counts).map((d) => d.id).toList(), [1, 2, 3]);
  });

  test('custom range is inclusive on both ends', () {
    final state = LibraryFilterState.defaults.copyWith(
      dateFilter: LibraryDateFilter.customRange,
      customStart: today.subtract(const Duration(days: 20)),
      customEnd: today.subtract(const Duration(days: 3)),
    );
    expect(state.apply(docs, counts).map((d) => d.id).toList(), [2, 3]);
  });

  test('oldest first reverses the default order', () {
    final state = LibraryFilterState.defaults.copyWith(
      sort: LibrarySort.oldestFirst,
    );
    expect(state.apply(docs, counts).map((d) => d.id).toList(), [4, 3, 2, 1]);
  });

  test('filename A-Z is case-insensitive', () {
    final state = LibraryFilterState.defaults.copyWith(
      sort: LibrarySort.filenameAZ,
    );
    expect(state.apply(docs, counts).map((d) => d.title).toList(), [
      'algebra',
      'Ancient history',
      'Cells',
      'Zoology',
    ]);
  });

  test('most study sets sorts by count, newest first on ties', () {
    final state = LibraryFilterState.defaults.copyWith(
      sort: LibrarySort.mostStudySets,
    );
    expect(state.apply(docs, counts).map((d) => d.id).toList(), [2, 3, 1, 4]);
  });

  test('reset restores the defaults', () {
    final state = LibraryFilterState.defaults
        .copyWith(
          sort: LibrarySort.filenameAZ,
          fileTypes: {DocumentFormat.pdf},
          dateFilter: LibraryDateFilter.last7Days,
        )
        .copyWith(
          sort: LibrarySort.newestFirst,
          fileTypes: {},
          dateFilter: LibraryDateFilter.anyTime,
          clearCustomRange: true,
        );
    expect(state.isDefault, isTrue);
  });
}

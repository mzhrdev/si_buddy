import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../providers/library_providers.dart';
import '../widgets/filter_selection_chip.dart';
import '../widgets/import_action_buttons.dart';

/// Library filters & sorting, implemented from the Figma frame
/// "SI Buddy · Library Filters & Sorting" (4:11655).
///
/// The screen edits a draft of the library filter state: Apply
/// writes it to [libraryFilterProvider] (the list and grid screens
/// render the filtered result immediately), Reset restores the
/// defaults, and the match count and "Show N documents" button are
/// computed from the real library — never sample numbers. The
/// custom date range opens a real date-range picker.
///
/// DOCX is not listed: the app imports PDF and PPTX only, so a DOCX
/// filter could never match anything.
class LibraryFiltersSortingScreen extends ConsumerStatefulWidget {
  const LibraryFiltersSortingScreen({super.key});

  @override
  ConsumerState<LibraryFiltersSortingScreen> createState() =>
      _LibraryFiltersSortingScreenState();
}

class _LibraryFiltersSortingScreenState
    extends ConsumerState<LibraryFiltersSortingScreen> {
  late LibraryFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(libraryFilterProvider);
  }

  void _resetAll() {
    setState(() => _draft = LibraryFilterState.defaults);
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _draft.customStart != null && _draft.customEnd != null
          ? DateTimeRange(start: _draft.customStart!, end: _draft.customEnd!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
    );
    if (range == null) return;
    setState(() {
      _draft = _draft.copyWith(
        dateFilter: LibraryDateFilter.customRange,
        customStart: range.start,
        customEnd: range.end,
      );
    });
  }

  String _customRangeLabel() {
    final start = _draft.customStart;
    final end = _draft.customEnd;
    if (start == null || end == null) return 'Custom range';
    return '${formatLibraryDate(start)} – ${formatLibraryDate(end)} · Includes both dates';
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsStreamProvider).value ?? const [];
    final counts = ref.watch(deckCountsByDocumentProvider).value ?? const {};
    final subjects = ref.watch(librarySubjectsProvider).value ?? const [];
    final matching = _draft.apply(documents, counts);

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Filters & sorting', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeading(
                              title: 'Sort by',
                              actionLabel: 'Reset all',
                              onAction: _resetAll,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final option in LibrarySort.values)
                                  FilterSelectionChip(
                                    label: option.label,
                                    selected: _draft.sort == option,
                                    onTap: () => setState(
                                      () => _draft = _draft.copyWith(
                                        sort: option,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 21),
                            const _SectionHeading(title: 'File type'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final type in [
                                  DocumentFormat.pdf,
                                  DocumentFormat.pptx,
                                ])
                                  FilterSelectionChip(
                                    label: type.label,
                                    selected: _draft.fileTypes.contains(type),
                                    onTap: () => setState(() {
                                      final types = Set<DocumentFormat>.of(
                                        _draft.fileTypes,
                                      );
                                      if (types.contains(type)) {
                                        types.remove(type);
                                      } else {
                                        types.add(type);
                                      }
                                      _draft = _draft.copyWith(
                                        fileTypes: types,
                                      );
                                    }),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 21),
                            const _SectionHeading(title: 'Subject'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterSelectionChip(
                                  label: 'Unassigned',
                                  selected: _draft.subjectIds.contains(null),
                                  onTap: () => setState(() {
                                    final ids = Set<int?>.of(_draft.subjectIds);
                                    if (ids.contains(null)) {
                                      ids.remove(null);
                                    } else {
                                      ids.add(null);
                                    }
                                    _draft = _draft.copyWith(subjectIds: ids);
                                  }),
                                ),
                                for (final subject in subjects)
                                  FilterSelectionChip(
                                    label: subject.name,
                                    selected: _draft.subjectIds.contains(
                                      subject.id,
                                    ),
                                    onTap: () => setState(() {
                                      final ids = Set<int?>.of(
                                        _draft.subjectIds,
                                      );
                                      if (ids.contains(subject.id)) {
                                        ids.remove(subject.id);
                                      } else {
                                        ids.add(subject.id);
                                      }
                                      _draft = _draft.copyWith(subjectIds: ids);
                                    }),
                                  ),
                                if (subjects.isEmpty)
                                  Text(
                                    'No subjects yet — create one from Organize documents.',
                                    style: AppTextStyles.caption(context),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 21),
                            const _SectionHeading(title: 'Import date'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final option in LibraryDateFilter.values)
                                  FilterSelectionChip(
                                    label: option.label,
                                    selected: _draft.dateFilter == option,
                                    iconAsset:
                                        option == LibraryDateFilter.customRange
                                        ? 'assets/icons/figma/calendar_days.svg'
                                        : null,
                                    onTap: () {
                                      if (option ==
                                          LibraryDateFilter.customRange) {
                                        _pickCustomRange();
                                      } else {
                                        setState(
                                          () => _draft = _draft.copyWith(
                                            dateFilter: option,
                                            clearCustomRange: true,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                            if (_draft.dateFilter ==
                                LibraryDateFilter.customRange) ...[
                              const SizedBox(height: 10),
                              Text(
                                _customRangeLabel(),
                                style: AppTextStyles.caption(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${matching.length} of ${documents.length} document${documents.length == 1 ? '' : 's'} match${matching.length == 1 ? 'es' : ''} your filters',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: context.appMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ImportPrimaryButton(
                          label:
                              'Show ${matching.length} document${matching.length == 1 ? '' : 's'}',
                          onPressed: () {
                            ref
                                .read(libraryFilterProvider.notifier)
                                .set(_draft);
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section heading row for a filter group, with an optional right-hand
/// action link ("Reset all").
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title(context)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppTextStyles.link(context)),
          ),
      ],
    );
  }
}

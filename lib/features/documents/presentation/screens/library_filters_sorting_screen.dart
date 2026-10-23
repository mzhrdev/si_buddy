import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/filter_selection_chip.dart';
import '../widgets/import_action_buttons.dart';

/// Library filters & sorting, implemented from the Figma frame
/// "SI Buddy · Library Filters & Sorting" (4:11655). Chip groups are
/// locally selectable; "Reset all" restores the design's defaults.
class LibraryFiltersSortingScreen extends StatefulWidget {
  const LibraryFiltersSortingScreen({super.key});

  @override
  State<LibraryFiltersSortingScreen> createState() =>
      _LibraryFiltersSortingScreenState();
}

class _LibraryFiltersSortingScreenState
    extends State<LibraryFiltersSortingScreen> {
  static const _sortOptions = [
    'Newest first',
    'Oldest first',
    'Filename A–Z',
    'Most study sets',
  ];
  static const _fileTypes = ['PDF', 'DOCX', 'PPTX'];
  static const _subjects = ['Biology', 'Chemistry', 'Research', 'Unassigned'];
  static const _dateOptions = [
    'Any time',
    'Last 7 days',
    'Last 30 days',
    'Custom range',
  ];

  String _sort = 'Newest first';
  final Set<String> _selectedTypes = {'PDF'};
  final Set<String> _selectedSubjects = {'Biology'};
  String _date = 'Last 7 days';

  void _resetAll() {
    setState(() {
      _sort = 'Newest first';
      _selectedTypes
        ..clear()
        ..add('PDF');
      _selectedSubjects
        ..clear()
        ..add('Biology');
      _date = 'Last 7 days';
    });
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    Column(
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
                            for (final option in _sortOptions)
                              FilterSelectionChip(
                                label: option,
                                selected: _sort == option,
                                onTap: () => setState(() => _sort = option),
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
                            for (final type in _fileTypes)
                              FilterSelectionChip(
                                label: type,
                                selected: _selectedTypes.contains(type),
                                onTap: () => _toggle(_selectedTypes, type),
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
                            for (final subject in _subjects)
                              FilterSelectionChip(
                                label: subject,
                                selected: _selectedSubjects.contains(subject),
                                onTap: () =>
                                    _toggle(_selectedSubjects, subject),
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
                            for (final option in _dateOptions)
                              FilterSelectionChip(
                                label: option,
                                selected: _date == option,
                                iconAsset: option == 'Custom range'
                                    ? 'assets/icons/figma/calendar_days.svg'
                                    : null,
                                onTap: () => setState(() => _date = option),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '10–16 Oct 2026 · Includes both dates',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '2 of 4 documents match your filters',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ImportPrimaryButton(
                          label: 'Show 2 documents',
                          onPressed: () => context.pop(),
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
        Text(title, style: AppTextStyles.title),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppTextStyles.link),
          ),
      ],
    );
  }
}

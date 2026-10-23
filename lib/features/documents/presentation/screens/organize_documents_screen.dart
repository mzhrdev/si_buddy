import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Organize documents, implemented from the Figma frame
/// "SI Buddy · Organize Documents" (4:12019).
///
/// Folder and subject are selectable locally; the summary line and
/// the pinned bottom navigation from the Figma frame are handled by
/// state here and the app shell respectively (the frame's own bottom
/// navigation is not rebuilt).
class OrganizeDocumentsScreen extends StatefulWidget {
  const OrganizeDocumentsScreen({super.key});

  @override
  State<OrganizeDocumentsScreen> createState() =>
      _OrganizeDocumentsScreenState();
}

class _OrganizeDocumentsScreenState extends State<OrganizeDocumentsScreen> {
  static const _folders = [
    ('Semester 1', '3 documents'),
    ('Coursework', '1 document'),
  ];
  static const _subjects = ['Biology', 'Chemistry', 'Research', 'No subject'];

  // Defaults match the design: Coursework selected, Biology assigned.
  int _selectedFolder = 1;
  int _selectedSubject = 0;

  String get _summary {
    final folder = _folders[_selectedFolder].$1;
    final subject = _subjects[_selectedSubject];
    if (subject == 'No subject') {
      return 'Move to $folder · No subject';
    }
    return 'Move to $folder · Keep $subject';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Organize documents', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1 DOCUMENT SELECTED',
                          style: AppTextStyles.captionAccent,
                        ),
                        const SizedBox(height: 10),
                        const _SelectedFileCard(),
                        const SizedBox(height: 24),
                        _SectionHeading(
                          title: 'Move to folder',
                          actionLabel: '+ New folder',
                          onAction: () {
                            // TODO(backend): create a new folder.
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Choose where this document lives.',
                          style: AppTextStyles.muted.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < _folders.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _FolderRow(
                            name: _folders[i].$1,
                            count: _folders[i].$2,
                            selected: i == _selectedFolder,
                            onTap: () => setState(() => _selectedFolder = i),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _SectionHeading(
                          title: 'Assign subject',
                          actionLabel: '+ Add subject',
                          onAction: () {
                            // TODO(backend): add a new subject.
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Subjects label a topic, regardless of folder.',
                          style: AppTextStyles.muted.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < _subjects.length; i++)
                              _SubjectChip(
                                label: _subjects[i],
                                selected: i == _selectedSubject,
                                onTap: () =>
                                    setState(() => _selectedSubject = i),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/folder_input.svg',
                              width: 15,
                              height: 15,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _summary,
                              style: AppTextStyles.muted.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            // TODO(backend): persist the organization.
                            context.pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Move & save changes'),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/icons/figma/arrow_right.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
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

/// Card for the single selected document at the top of the screen.
class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: SvgPicture.asset(
              'assets/icons/figma/file_check_2.svg',
              width: 21,
              height: 21,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cell Biology - Chapter 4.pdf',
                  style: AppTextStyles.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Currently: Semester 1 · Biology',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title with a trailing text action ("+ New folder").
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        GestureDetector(
          onTap: onAction,
          child: Text(actionLabel, style: AppTextStyles.link),
        ),
      ],
    );
  }
}

/// One destination folder row with a radio-style trailing indicator.
class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.name,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/folder.svg',
                width: 21,
                height: 21,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.itemTitle),
                    const SizedBox(height: 3),
                    Text(count, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/figma/check.svg',
                    width: 11,
                    height: 11,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/icons/figma/circle.svg',
                  width: 20,
                  height: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One subject selection chip.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                SvgPicture.asset(
                  'assets/icons/figma/check.svg',
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: selected
                    ? AppTextStyles.link
                    : AppTextStyles.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

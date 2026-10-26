import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_destinations_bar.dart';
import '../widgets/study_material_row.dart';
import '../widgets/study_section_heading.dart';

/// Study Library, implemented from the Figma frame
/// "SI Buddy · Study Library" (5:11311).
///
/// Tab root of the Study branch: destinations bar, subject/progress
/// filter chips, folder shortcuts, and the subject's study materials.
class StudyLibraryScreen extends StatefulWidget {
  const StudyLibraryScreen({super.key});

  @override
  State<StudyLibraryScreen> createState() => _StudyLibraryScreenState();
}

class _StudyLibraryScreenState extends State<StudyLibraryScreen> {
  String _subject = 'Biology';
  String _progress = 'All progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Study library'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 0),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Builder(
                        builder: (chipContext) => _FilterChip(
                          label: _subject,
                          selected: true,
                          onTap: () => _pickSubject(chipContext),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (chipContext) => _FilterChip(
                          label: _progress,
                          selected: false,
                          onTap: () => _pickProgress(chipContext),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StudySectionHeading(
                    title: 'Folders',
                    actionLabel: '+ New folder',
                    onAction: () => context.push(AppRoutes.createFolder),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _FolderCard(
                          name: 'Semester 1',
                          caption: '4 study items',
                          // TODO(backend): open the folder's contents.
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FolderCard(
                          name: 'Coursework',
                          caption: 'No study items',
                          // TODO(backend): open the folder's contents.
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StudySectionHeading(
                    title: 'Biology materials',
                    actionLabel: 'View subject →',
                    onAction: () => context.push(AppRoutes.subject),
                  ),
                  const SizedBox(height: 2),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/layers.svg',
                    typeLabel: 'DECK',
                    title: 'Cell structures',
                    meta: '20 cards · 12 mastered · 3 difficult',
                    status: 'Reviewed today',
                    onTap: () => context.push(AppRoutes.deck),
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/list_checks.svg',
                    typeLabel: 'QUIZ',
                    title: 'Cell structures',
                    meta: '10 questions · Latest score 7/10',
                    status: '3 attempts · 70% latest',
                    onTap: () => context.push(AppRoutes.history),
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/file_text.svg',
                    typeLabel: 'SUMMARY',
                    title: 'Cell Biology · Chapter 4',
                    meta: '5 key sections · Biology',
                    status: 'Read 3 of 5 sections',
                    // TODO(backend): open the generated summary.
                    onTap: () {},
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/bookmark.svg',
                    typeLabel: 'SAVED QUESTIONS',
                    title: 'Membranes & organelles',
                    meta: '4 questions · Biology',
                    status: '2 of 4 reviewed',
                    onTap: () => context.push(AppRoutes.revision),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'All 4 items saved locally · Available offline',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSubject(BuildContext context) async {
    final value = await _showFilterMenu(context, _subject, const ['Biology']);
    if (value != null) setState(() => _subject = value);
  }

  Future<void> _pickProgress(BuildContext context) async {
    final value = await _showFilterMenu(context, _progress, const [
      'All progress',
    ]);
    if (value != null) setState(() => _progress = value);
  }

  /// Anchors a small selection menu under the tapped filter chip.
  Future<String?> _showFilterMenu(
    BuildContext context,
    String current,
    List<String> options,
  ) {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return showMenu<String>(
      context: context,
      position: position,
      initialValue: current,
      items: [
        for (final option in options)
          PopupMenuItem<String>(value: option, child: Text(option)),
      ],
    );
  }
}

/// A dropdown filter chip; the selected variant uses the selected
/// surface with a primary border and primary semibold label.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      color: selected ? AppColors.surface : AppColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: selected ? 16 / 12 : 18 / 12,
                  color: selected ? AppColors.primary : AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              SvgPicture.asset(
                'assets/icons/figma/chevron_down.svg',
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(
                  selected ? AppColors.primary : AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A folder shortcut card with a primary folder icon, name, and a
/// bold muted item-count caption.
class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.name,
    required this.caption,
    required this.onTap,
  });

  final String name;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 58,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/folder.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 16 / 12,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

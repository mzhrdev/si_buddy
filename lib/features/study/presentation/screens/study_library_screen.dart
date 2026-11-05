import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../widgets/study_destinations_bar.dart';
import '../widgets/study_material_row.dart';
import '../widgets/study_section_heading.dart';

/// Study Library, implemented from the Figma frame
/// "SI Buddy · Study Library" (5:11311).
///
/// Tab root of the Study branch: destinations bar, subject/progress
/// filter chips, and the study materials from this session's
/// generation. Decks and quizzes are session-only until persistence
/// lands, so only this session's generated materials appear; without
/// any, the materials section shows an honest empty state. Folders
/// are not shown: none can exist yet (no folder persistence).
class StudyLibraryScreen extends ConsumerStatefulWidget {
  const StudyLibraryScreen({super.key});

  @override
  ConsumerState<StudyLibraryScreen> createState() => _StudyLibraryScreenState();
}

class _StudyLibraryScreenState extends ConsumerState<StudyLibraryScreen> {
  String _progress = 'All progress';

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final ratings = ref.watch(cardRatingsProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final subject = ref.watch(extractionProvider).subject;
    final cards = result?.flashcards ?? const [];
    final questions = result?.questions ?? const [];
    final title = generatedMaterialTitle(
      config: config,
      documentName: job.source?.document.originalFileName,
    );
    final mastered = ratings.values.where((r) => r == 'Easy').length;
    final difficult = ratings.values.where((r) => r == 'Hard').length;
    final reviewed = ratings.length;
    final answered = questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false),
        )
        .length;
    final correct = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    final subjectLabel = subject ?? 'All subjects';
    final itemCount = (cards.isNotEmpty ? 1 : 0) + (questions.isNotEmpty ? 1 : 0);
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
                          label: subjectLabel,
                          selected: true,
                          onTap: () => _pickSubject(chipContext, subjectLabel),
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
                    title: subject == null ? 'Your materials' : '$subject materials',
                    actionLabel: 'View subject →',
                    onAction: () => context.push(AppRoutes.subject),
                  ),
                  const SizedBox(height: 2),
                  if (cards.isNotEmpty)
                    StudyMaterialRow(
                      iconAsset: 'assets/icons/figma/layers.svg',
                      typeLabel: 'DECK',
                      title: title,
                      meta:
                          '${cards.length} cards · $mastered mastered · $difficult difficult',
                      status: reviewed > 0
                          ? 'Reviewed today'
                          : 'Not reviewed yet',
                      onTap: () => context.push(AppRoutes.deck),
                    ),
                  if (questions.isNotEmpty)
                    StudyMaterialRow(
                      iconAsset: 'assets/icons/figma/list_checks.svg',
                      typeLabel: 'QUIZ',
                      title: title,
                      meta: answered > 0
                          ? '${questions.length} questions · Latest score $correct/${questions.length}'
                          : '${questions.length} questions · Not taken yet',
                      status: answered > 0
                          ? '$answered of ${questions.length} answered'
                          : 'Not started',
                      onTap: () => context.push(AppRoutes.history),
                    ),
                  if (itemCount == 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: 'No study materials yet',
                        message:
                            'Generate flashcards or a quiz from a document to see them here.',
                      ),
                    )
                  else ...[
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount item${itemCount == 1 ? '' : 's'} saved locally · Available offline',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSubject(BuildContext context, String current) async {
    final value = await _showFilterMenu(context, current, [current]);
    if (value != null) setState(() {});
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


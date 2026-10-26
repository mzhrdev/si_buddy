import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../documents/domain/document_failures.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../domain/generation_config.dart';
import '../../domain/generation_failures.dart';
import '../../domain/generation_models.dart';
import '../providers/generation_providers.dart';
import '../widgets/generation_selections.dart';
import '../widgets/generation_source_card.dart';

/// Local generation processing, implemented from the Figma frame
/// "SI Buddy · Local generation processing" (5:596).
///
/// When a generation job is running (started from setup's Generate),
/// the frame renders the job's live state — real source document,
/// progress, stage checklist and preserved selections — and routes
/// on completion to the generated material's screen, or on failure
/// to the designed error screen for that failure (missing model,
/// low memory, insufficient text, generation failure). Opened with
/// no job, it keeps the design's static state: 40%, with the three
/// generation stages (complete / active / upcoming) and the
/// preserved selections from setup.
class LocalGenerationProcessingScreen extends ConsumerStatefulWidget {
  const LocalGenerationProcessingScreen({super.key});

  @override
  ConsumerState<LocalGenerationProcessingScreen> createState() =>
      _LocalGenerationProcessingScreenState();
}

class _LocalGenerationProcessingScreenState
    extends ConsumerState<LocalGenerationProcessingScreen> {
  bool _navigated = false;

  /// Where a completed job lands: the screen that presents its
  /// material type (flashcards and summaries live in decks).
  String _routeForResult(GenerationConfig? config) {
    return switch (config?.materialType) {
      GenerationMaterialType.mcqs => AppRoutes.mcq,
      GenerationMaterialType.trueFalse => AppRoutes.trueFalse,
      GenerationMaterialType.shortAnswers => AppRoutes.shortAnswer,
      _ => AppRoutes.deck,
    };
  }

  /// Where a failed job lands: the designed error screen for the
  /// failure, or null for failures with no designed destination
  /// (the screen then stays, showing the frozen progress).
  String? _routeForError(Object? error) {
    return switch (error) {
      ModelNotInstalledFailure() => AppRoutes.missingModel,
      LowMemoryFailure() => AppRoutes.generationLowMemory,
      InsufficientTextException() => AppRoutes.insufficientText,
      GenerationFailure() => AppRoutes.generationFailure,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GenerationJobState>(generationJobProvider, (previous, next) {
      if (_navigated || previous?.status == next.status) return;
      final route = switch (next.status) {
        GenerationJobStatus.completed => _routeForResult(next.config),
        GenerationJobStatus.failed => _routeForError(next.error),
        _ => null,
      };
      if (route != null) {
        _navigated = true;
        context.pushReplacement(route);
      }
    });

    final job = ref.watch(generationJobProvider);
    final live = job.status != GenerationJobStatus.idle;
    final jobSource = live ? job.source : null;
    final config = job.config;
    final subject = ref.watch(extractionProvider).subject;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'AI generation', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (jobSource != null)
                      GenerationSourceCard(
                        title: jobSource.document.originalFileName,
                        subtitle: generationSourceSubtitle(
                          document: jobSource.document,
                          subject: subject,
                        ),
                        formatLabel: jobSource.document.format.label,
                      )
                    else
                      const GenerationSourceCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Creating your flashcards',
                      style: AppTextStyles.display.copyWith(
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The local AI is turning your reviewed text into study material.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        height: 22 / 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generating cards',
                          style: AppTextStyles.link.copyWith(height: 16 / 12),
                        ),
                        Text(
                          live ? '${(job.fraction * 100).round()}%' : '40%',
                          style: AppTextStyles.link.copyWith(height: 16 / 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: live ? job.fraction : 0.4,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This may take a minute. Keep SI Buddy open.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GenerationStages(job: live ? job : null),
                    const SizedBox(height: 24),
                    if (live && config != null)
                      GenerationSelections(
                        summaryLine:
                            '${config.count} ${_materialNoun(config.materialType)} · ${config.difficulty.label} · ${config.language}',
                        detailLine:
                            '${config.topic} · Explanations ${config.includeExplanations ? 'on' : 'off'}',
                      )
                    else
                      const GenerationSelections(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Model installed · Running on this device',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      height: 18 / 12,
                      color: AppColors.successText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Cancels the running job (the model stops
                      // generating; nothing is saved); with no job
                      // this simply leaves the design state.
                      if (live) {
                        ref.read(generationJobProvider.notifier).cancel();
                      }
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma/shield_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.navInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your notes stay on your device.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The countable noun for the selections line ('20 flashcards',
  /// '20 MCQs', …), following the design's wording.
  String _materialNoun(GenerationMaterialType type) {
    return switch (type) {
      GenerationMaterialType.flashcards => 'flashcards',
      GenerationMaterialType.mcqs => 'MCQs',
      GenerationMaterialType.trueFalse => 'true/false questions',
      GenerationMaterialType.shortAnswers => 'short answers',
      GenerationMaterialType.summaries => 'summaries',
    };
  }
}

/// The three-stage generation list inside its bordered card:
/// extraction complete, local AI generation, then check and save.
/// With a null [job] it renders the design's static rows; with a
/// job, each row's state and subtitle come from the job.
class _GenerationStages extends StatelessWidget {
  const _GenerationStages({this.job});

  final GenerationJobState? job;

  @override
  Widget build(BuildContext context) {
    final rows = <({JobStageStatus status, String title, String subtitle})>[
      if (job == null) ...[
        (
          status: JobStageStatus.complete,
          title: 'Text extraction complete',
          subtitle: 'Reviewed source text is ready',
        ),
        (
          status: JobStageStatus.active,
          title: 'Local AI generation',
          subtitle: 'Building cards about cell structures',
        ),
        (
          status: JobStageStatus.upcoming,
          title: 'Check and save',
          subtitle: 'Starts after generation finishes',
        ),
      ] else
        for (final stage in GenerationStage.values)
          (
            status: job!.statusOf(stage),
            title: stage.label,
            subtitle: job!.subtitleFor(stage),
          ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _StageRow(
              indicator: switch (rows[i].status) {
                JobStageStatus.complete => Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/figma/check.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                JobStageStatus.active => SvgPicture.asset(
                  'assets/icons/figma/stage_active.svg',
                  width: 28,
                  height: 28,
                ),
                JobStageStatus.upcoming => SvgPicture.asset(
                  'assets/icons/figma/stage_upcoming.svg',
                  width: 28,
                  height: 28,
                ),
              },
              title: rows[i].title,
              titleColor: rows[i].status == JobStageStatus.active
                  ? AppColors.primary
                  : null,
              subtitle: rows[i].subtitle,
            ),
          ],
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.indicator,
    required this.title,
    required this.subtitle,
    this.titleColor,
  });

  final Widget indicator;
  final String title;
  final String subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        indicator,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.itemTitle.copyWith(color: titleColor),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

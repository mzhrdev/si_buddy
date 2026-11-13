import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
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
/// no job, it shows an honest empty state — never the design's
/// static 40% state with sample selections.
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
  /// failure. Any failure without a designed destination routes to
  /// the generation-failure screen — the job must never end on a
  /// frozen progress screen with no explanation.
  String _routeForError(Object? error) {
    return switch (error) {
      ModelNotInstalledFailure() => AppRoutes.missingModel,
      LowMemoryFailure() => AppRoutes.generationLowMemory,
      InsufficientTextException() => AppRoutes.insufficientText,
      GenerationFailure() => AppRoutes.generationFailure,
      _ => AppRoutes.generationFailure,
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
    if (!live) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'AI generation', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.auto_awesome_outlined,
                  title: 'No generation in progress',
                  message:
                      'Generate flashcards or a quiz from one of your documents to see progress here.',
                  actionLabel: 'Import a document',
                  onAction: () => context.pushReplacement(AppRoutes.importFiles),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final jobSource = job.source;
    final config = job.config;
    final subject = ref.watch(extractionProvider).subject;

    return Scaffold(
      backgroundColor: context.appBackground,
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
                      style: AppTextStyles.display(
                        context,
                      ).copyWith(letterSpacing: -0.48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The AI service is turning your reviewed text into study material.',
                      style: AppTextStyles.body(
                        context,
                      ).copyWith(color: context.appMuted, height: 22 / 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generating cards',
                          style: AppTextStyles.link(
                            context,
                          ).copyWith(height: 16 / 12),
                        ),
                        Text(
                          '${(job.fraction * 100).round()}%',
                          style: AppTextStyles.link(
                            context,
                          ).copyWith(height: 16 / 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: job.fraction,
                        minHeight: 6,
                        backgroundColor: context.appSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.appPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This may take a minute. Keep SI Buddy open.',
                      style: AppTextStyles.caption(
                        context,
                      ).copyWith(fontSize: 12, height: 18 / 12),
                    ),
                    const SizedBox(height: 24),
                    _GenerationStages(job: job),
                    const SizedBox(height: 24),
                    if (config != null)
                      GenerationSelections(
                        summaryLine:
                            '${config.count} ${_materialNoun(config.materialType)} · ${config.difficulty.label} · ${config.language}',
                        detailLine:
                            '${config.topic.isEmpty ? 'No topic set' : config.topic} · Explanations ${config.includeExplanations ? 'on' : 'off'}',
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
                    'AI service connected · Generating online',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: 12,
                      height: 18 / 12,
                      color: context.appSuccessText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Cancels the running job (the model stops
                      // generating; nothing is saved).
                      ref.read(generationJobProvider.notifier).cancel();
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: context.appBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: context.appPrimary,
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
                        colorFilter: ColorFilter.mode(
                          context.appNavInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your notes stay on your device.',
                        style: AppTextStyles.caption(context),
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
/// extraction complete, AI generation, then check and save.
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
          title: 'AI generation',
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
        border: Border.all(color: context.appBorder),
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
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/figma/check.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      context.appPrimary,
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
                  ? context.appPrimary
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
                style: AppTextStyles.itemTitle(
                  context,
                ).copyWith(color: titleColor),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption(
                  context,
                ).copyWith(fontSize: 12, height: 18 / 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

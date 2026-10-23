import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/document_failures.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/selected_document_card.dart';

/// Text extraction processing, implemented from the Figma frame
/// "SI Buddy · Text extraction processing" (4:4971).
///
/// While an extraction job runs, the document card, progress dial and
/// the three-stage checklist are driven live by [extractionProvider];
/// completion continues to the extracted-text review and a failure
/// routes to its designed error screen. Opened without a job, the
/// screen shows the design's static progress state (60%, page 7 of
/// 12, with the three processing stages complete / active / upcoming).
class TextExtractionProcessingScreen extends ConsumerWidget {
  const TextExtractionProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExtractionState>(extractionProvider, (previous, next) {
      if (previous?.status == next.status) return;
      if (next.status == ExtractionStatus.completed) {
        context.push(AppRoutes.extractionReview);
      } else if (next.status == ExtractionStatus.failed) {
        final route = switch (next.error) {
          UnsupportedFormatException() => AppRoutes.unsupported,
          InsufficientStorageException() => AppRoutes.storageError,
          _ => AppRoutes.corrupted,
        };
        context.pushReplacement(route);
      }
    });
    final state = ref.watch(extractionProvider);
    final live =
        state.status != ExtractionStatus.idle && state.file != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Extracting text', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: live
                    ? _LiveBody(
                        state: state,
                        onCancel: () {
                          ref.read(extractionProvider.notifier).cancel();
                          context.pop();
                        },
                      )
                    : _StaticBody(onCancel: () => context.pop()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The design's static progress state, shown when no job is running.
class _StaticBody extends StatelessWidget {
  const _StaticBody({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SelectedDocumentCard(
              title: 'Cell Biology - Chapter 4.pdf',
              subtitle: 'PDF · 2.4 MB · 12 pages',
            ),
            const SizedBox(height: 22),
            const _CurrentProgress(),
            const SizedBox(height: 22),
            const _ProcessingStages(),
          ],
        ),
        _BottomBlock(onCancel: onCancel),
      ],
    );
  }
}

/// The live progress state, driven by the running extraction job.
class _LiveBody extends StatelessWidget {
  const _LiveBody({required this.state, required this.onCancel});

  final ExtractionState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SelectedDocumentCard(
              title: state.documentTitle,
              subtitle: state.documentSubtitle,
              formatLabel: state.file!.format.label,
            ),
            const SizedBox(height: 22),
            _CurrentProgress(fraction: state.fraction),
            const SizedBox(height: 22),
            _LiveProcessingStages(state: state),
          ],
        ),
        _BottomBlock(onCancel: onCancel),
      ],
    );
  }
}

/// The note, cancel action and privacy line under the progress card.
class _BottomBlock extends StatelessWidget {
  const _BottomBlock({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Processing happens locally on this device. Your original file stays unchanged.',
          style: AppTextStyles.muted.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Cancel extraction',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const PrivacyReassurance(
          text: 'Nothing is uploaded. No internet needed.',
        ),
      ],
    );
  }
}

/// Circular progress dial with the state message below it.
class _CurrentProgress extends StatelessWidget {
  const _CurrentProgress({this.fraction = 0.6});

  /// Dial fill and percentage; the design's static state is 60%.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 94,
                height: 94,
                child: CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: AppTextStyles.display.copyWith(
                  fontSize: 28,
                  height: 34 / 28,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Making your notes readable.',
          style: AppTextStyles.display.copyWith(fontSize: 28, height: 34 / 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Turning your document into text you can review before you study.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.muted,
            height: 22 / 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The stage checklist card in the design's static state.
class _ProcessingStages extends StatelessWidget {
  const _ProcessingStages();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _StageRow(
            indicator: _completeStageIndicator(),
            title: 'Reading Document',
            subtitle: 'Complete · 12 pages found',
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _StageRow(
                indicator: _activeStageIndicator(),
                title: 'Extracting Text',
                subtitle: 'Processing page 7 of 12',
                subtitleColor: AppColors.primary,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _StageRow(
            indicator: _upcomingStageIndicator(),
            title: 'Preparing Content',
            subtitle: 'Up next · organize text for review',
            muted: true,
          ),
        ],
      ),
    );
  }
}

/// The stage checklist card driven by a running extraction job.
class _LiveProcessingStages extends StatelessWidget {
  const _LiveProcessingStages({required this.state});

  final ExtractionState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          for (var i = 0; i < ExtractionStage.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _stageBlock(ExtractionStage.values[i]),
          ],
        ],
      ),
    );
  }

  Widget _stageBlock(ExtractionStage stage) {
    final status = state.statusOf(stage);
    final row = _StageRow(
      indicator: switch (status) {
        StageStatus.complete => _completeStageIndicator(),
        StageStatus.active => _activeStageIndicator(),
        StageStatus.upcoming => _upcomingStageIndicator(),
      },
      title: stage.label,
      subtitle: state.subtitleFor(stage),
      subtitleColor: status == StageStatus.active ? AppColors.primary : null,
      muted: status == StageStatus.upcoming,
    );
    if (stage == ExtractionStage.extractingText &&
        status == StageStatus.active) {
      return Column(
        children: [
          row,
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: state.stageFraction,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      );
    }
    return row;
  }
}

Widget _completeStageIndicator() {
  return Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.primary,
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SvgPicture.asset(
      'assets/icons/figma/check.svg',
      width: 16,
      height: 16,
      colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
    ),
  );
}

Widget _activeStageIndicator() {
  return SvgPicture.asset(
    'assets/icons/figma/stage_active.svg',
    width: 32,
    height: 32,
  );
}

Widget _upcomingStageIndicator() {
  return SvgPicture.asset(
    'assets/icons/figma/stage_upcoming.svg',
    width: 32,
    height: 32,
  );
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.indicator,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.muted = false,
  });

  final Widget indicator;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.body.copyWith(
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      color: muted ? AppColors.muted : AppColors.text,
    );
    return Row(
      children: [
        indicator,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

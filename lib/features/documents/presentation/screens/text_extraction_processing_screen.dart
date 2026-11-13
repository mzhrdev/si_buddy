import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/document_failures.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/selected_document_card.dart';

/// Where a completed extraction continues: the extracted-text review,
/// or the scanned-PDF screen when a PDF yielded no readable text even
/// after OCR — the review would only show empty pages, so the user
/// gets the explanation and a way to pick another file instead.
String routeAfterExtraction(ExtractedDocument result) {
  if (!result.hasText && result.document.format == DocumentFormat.pdf) {
    return AppRoutes.ocr;
  }
  return AppRoutes.extractionReview;
}

/// Text extraction processing, implemented from the Figma frame
/// "SI Buddy · Text extraction processing" (4:4971).
///
/// While an extraction job runs, the document card, progress dial and
/// the three-stage checklist are driven live by [extractionProvider];
/// completion continues to the extracted-text review and a failure
/// routes to its designed error screen. Opened without a job, the
/// screen shows an honest empty state — never the design's static
/// progress state (60%, page 7 of 12).
class TextExtractionProcessingScreen extends ConsumerWidget {
  const TextExtractionProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExtractionState>(extractionProvider, (previous, next) {
      if (previous?.status == next.status) return;
      if (next.status == ExtractionStatus.completed) {
        final result = next.result;
        if (result == null) return;
        // The processing screen replaces itself for every
        // destination: going back from the next screen should
        // leave the import flow, not return to a finished
        // checklist.
        final route = routeAfterExtraction(result);
        context.pushReplacement(route);
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
      backgroundColor: context.appBackground,
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
                    : const EmptyState(
                        icon: Icons.description_outlined,
                        title: 'No extraction in progress',
                        message:
                            'Import a document first — its text extraction will appear here.',
                      ),
              ),
            ),
          ],
        ),
      ),
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
          style: AppTextStyles.muted(context).copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.appBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Cancel extraction',
              style: AppTextStyles.body(context).copyWith(
                fontWeight: FontWeight.w600,
                color: context.appPrimary,
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
                  backgroundColor: context.appBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.appPrimary,
                  ),
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: AppTextStyles.display(context).copyWith(
                  fontSize: 28,
                  height: 34 / 28,
                  color: context.appPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Making your notes readable.',
          style: AppTextStyles.display(context).copyWith(fontSize: 28, height: 34 / 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Turning your document into text you can review before you study.',
          style: AppTextStyles.body(context).copyWith(
            color: context.appMuted,
            height: 22 / 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          for (var i = 0; i < ExtractionStage.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _stageBlock(context, ExtractionStage.values[i]),
          ],
        ],
      ),
    );
  }

  Widget _stageBlock(BuildContext context, ExtractionStage stage) {
    final status = state.statusOf(stage);
    final row = _StageRow(
      indicator: switch (status) {
        StageStatus.complete => _completeStageIndicator(context),
        StageStatus.active => _activeStageIndicator(),
        StageStatus.upcoming => _upcomingStageIndicator(),
      },
      title: stage.label,
      subtitle: state.subtitleFor(stage),
      subtitleColor: status == StageStatus.active ? context.appPrimary : null,
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
              backgroundColor: context.appBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.appPrimary,
              ),
            ),
          ),
        ],
      );
    }
    return row;
  }
}

Widget _completeStageIndicator(BuildContext context) {
  return Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.appPrimary,
      border: Border.all(color: context.appPrimary),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SvgPicture.asset(
      'assets/icons/figma/check.svg',
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(context.appCard, BlendMode.srcIn),
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
    final titleStyle = AppTextStyles.body(context).copyWith(
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      color: muted ? context.appMuted : context.appText,
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
                style: AppTextStyles.caption(context).copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/selected_document_card.dart';

/// Text extraction processing, implemented from the Figma frame
/// "SI Buddy · Text extraction processing" (4:4971).
///
/// Static progress state from the design: 60%, page 7 of 12, with the
/// three processing stages (complete / active / upcoming).
class TextExtractionProcessingScreen extends StatelessWidget {
  const TextExtractionProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Extracting text', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
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
                    Column(
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
                            onPressed: () {
                              // TODO(backend): cancel the extraction job.
                            },
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

/// Circular progress dial (60%) with the state message below it.
class _CurrentProgress extends StatelessWidget {
  const _CurrentProgress();

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
                  value: 0.6,
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              Text(
                '60%',
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

/// The three-stage processing list inside its white bordered card.
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
            indicator: Container(
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
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            title: 'Reading Document',
            subtitle: 'Complete · 12 pages found',
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _StageRow(
                indicator: SvgPicture.asset(
                  'assets/icons/figma/stage_active.svg',
                  width: 32,
                  height: 32,
                ),
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
            indicator: SvgPicture.asset(
              'assets/icons/figma/stage_upcoming.svg',
              width: 32,
              height: 32,
            ),
            title: 'Preparing Content',
            subtitle: 'Up next · organize text for review',
            muted: true,
          ),
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

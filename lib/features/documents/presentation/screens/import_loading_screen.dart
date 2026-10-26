import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/selected_document_card.dart';
import '../widgets/state_message.dart';

/// Import progress, implemented from the Figma frame
/// "SI Buddy · Import loading" (4:3399): the selected document, a
/// circular reading indicator at 60%, a linear progress card and a
/// safe-cancel action. Values are static, as designed.
class ImportLoadingScreen extends StatelessWidget {
  const ImportLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Importing document', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SelectedDocumentCard(
                          title: 'Cell Biology - Chapter 4.pdf',
                          subtitle: 'PDF · 2.4 MB · 12 pages',
                        ),
                        const SizedBox(height: 24),
                        const _ReadingIllustration(),
                        const SizedBox(height: 20),
                        const StateMessage(
                          headline: 'Getting your notes ready.',
                          body:
                              'Reading the document and extracting its text. This may take a moment.',
                          centered: true,
                        ),
                        const SizedBox(height: 24),
                        const _ProgressDetailsCard(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/folder_open.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                AppColors.navInactive,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Next: save to Biology in your library',
                              style: AppTextStyles.greeting,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'You can cancel safely. Your original file won’t change.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.greeting,
                        ),
                        const SizedBox(height: 14),
                        ImportSecondaryButton(
                          label: 'Cancel import',
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 14),
                        const PrivacyReassurance(
                          text: 'Reading locally. Nothing is uploaded.',
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

/// Circular progress ring (60%) with the miniature reading document
/// centred over it, from the Figma reading illustration.
class _ReadingIllustration extends StatelessWidget {
  const _ReadingIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 156,
        child: Stack(
          children: [
            Positioned(
              left: 15,
              top: 13,
              child: SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: 0.6,
                  strokeWidth: 8,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 53,
              top: 43,
              child: Container(
                width: 54,
                height: 70,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/file_text.svg',
                      width: 25,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.primary,
                      ),
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

/// White card with the "Reading text · 60%" label row, the linear
/// progress track and the current page note.
class _ProgressDetailsCard extends StatelessWidget {
  const _ProgressDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reading text', style: AppTextStyles.itemTitle),
              Text(
                '60%',
                style: AppTextStyles.itemTitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text('Reading page 7 of 12', style: AppTextStyles.greeting),
        ],
      ),
    );
  }
}

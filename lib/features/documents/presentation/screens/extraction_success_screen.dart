import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/documents_providers.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/selected_document_card.dart';

/// Extraction success, implemented from the Figma frame
/// "SI Buddy · Extraction success" (4:5099).
///
/// The document is saved locally; the next study step offers
/// flashcards, a quiz, or viewing the document. When an extraction
/// job has completed, the copy and document card show the real
/// document; opened without one it shows an honest empty state.
class ExtractionSuccessScreen extends ConsumerWidget {
  const ExtractionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extraction = ref.watch(extractionProvider);
    final result = extraction.result;
    final document = result?.document;
    if (document == null) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Document ready', onBack: () => context.pop()),
              const Expanded(
                child: EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'No document was just imported',
                  message:
                      'Import a document first — this screen appears once its text is extracted.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    final subject = extraction.subject ?? 'Biology';
    final body =
        'All ${document.pageCount} ${document.format.unitLabel} are ready in your $subject library. Choose how you’d like to study next.';

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Document ready', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const _SuccessIllustration(),
                        const SizedBox(height: 20),
                        Text(
                          'Text extracted. All yours.',
                          style: AppTextStyles.display(context).copyWith(
                            fontSize: 28,
                            height: 34 / 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          body,
                          style: AppTextStyles.body(context).copyWith(
                            color: context.appMuted,
                            height: 22 / 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SelectedDocumentCard(
                          title: document.originalFileName,
                          subtitle:
                              '$subject · ${document.pageCount} ${document.format.unitLabel} · Saved locally',
                          formatLabel: document.format.label,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/check_check.svg',
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                context.appPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Extraction completed · Text reviewed',
                              style: AppTextStyles.link(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your next study step',
                          style: AppTextStyles.title(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No study materials have been generated yet.',
                          style: AppTextStyles.muted(context).copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.push(AppRoutes.generationSetup),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Generate Flashcards'),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/icons/figma/arrow_right.svg',
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  context.appCard,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push(AppRoutes.quizSetup),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Create Quiz'),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/icons/figma/arrow_right.svg',
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  context.appCard,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.push(AppRoutes.details),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.appBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/figma/file_text.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    context.appPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'View Document',
                                  style: AppTextStyles.body(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.appPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const PrivacyReassurance(
                          text: 'Saved privately. Ready to use offline.',
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

/// 132px illustration: an extracted document sheet with a primary
/// success badge overlapping its bottom-right corner.
class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        children: [
          Positioned(
            left: 42,
            top: 27,
            child: Container(
              width: 50,
              height: 68,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.appPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.appBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.appBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 19,
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.appBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 75,
            top: 77,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.appPrimary,
                border: Border.all(color: context.appCard, width: 3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                'assets/icons/figma/check.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  context.appCard,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/library_header.dart';
import '../widgets/note_sheet_illustration.dart';
import '../widgets/privacy_reassurance.dart';

/// Empty library (first run), implemented from the Figma frame
/// "SI Buddy · Empty Library" (4:11865).
class EmptyLibraryScreen extends StatelessWidget {
  const EmptyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const LibraryHeader(subtitle: '0 documents · A fresh start'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const NoteSheetIllustration(
                          badgeIconAsset: 'assets/icons/figma/folder_plus.svg',
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'A home for your notes.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            letterSpacing: -0.48,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Import your first document. Turn what you’re '
                          'learning into flashcards, quizzes and summaries.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                            height: 22 / 14,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ImportPrimaryButton(
                          label: 'Import Notes',
                          onPressed: () => context.push(AppRoutes.importFiles),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PDF, DOCX and PPTX supported',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
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
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/figma/folders.svg',
                                    width: 17,
                                    height: 17,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'A little order. A clearer mind.',
                                    style: AppTextStyles.itemTitle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Once you import, group notes into folders '
                                'and assign subjects to find them faster.',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const PrivacyReassurance(
                      text: 'No account. No cloud. Just your notes.',
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

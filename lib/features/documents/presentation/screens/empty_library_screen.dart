import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/library_header.dart';
import '../widgets/privacy_reassurance.dart';

/// Empty library (first run), implemented from the Figma frame
/// "SI Buddy · Empty Library" (4:11865).
class EmptyLibraryScreen extends StatelessWidget {
  const EmptyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
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
                        Text(
                          'A home for your notes.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display(
                            context,
                          ).copyWith(letterSpacing: -0.48),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Import your first document. Turn what you’re '
                          'learning into flashcards, quizzes and summaries.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            context,
                          ).copyWith(color: context.appMuted, height: 22 / 14),
                        ),
                        const SizedBox(height: 22),
                        ImportPrimaryButton(
                          label: 'Import Notes',
                          onPressed: () => context.push(AppRoutes.importFiles),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PDF and PPTX supported',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: context.appMuted,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.appCard,
                            border: Border.all(color: context.appBorder),
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
                                    colorFilter: ColorFilter.mode(
                                      context.appPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'A little order. A clearer mind.',
                                    style: AppTextStyles.itemTitle(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Once you import, group notes into folders '
                                'and assign subjects to find them faster.',
                                style: AppTextStyles.body(context).copyWith(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  color: context.appMuted,
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

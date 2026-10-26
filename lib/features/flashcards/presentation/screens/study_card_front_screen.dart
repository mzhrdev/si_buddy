import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_card_navigation.dart';
import '../widgets/study_session_header.dart';

/// Study card front (question face), implemented from the Figma frame
/// "SI Buddy · Study Card Front" (5:2558).
class StudyCardFrontScreen extends StatefulWidget {
  const StudyCardFrontScreen({super.key});

  @override
  State<StudyCardFrontScreen> createState() => _StudyCardFrontScreenState();
}

class _StudyCardFrontScreenState extends State<StudyCardFrontScreen> {
  bool _shuffleOn = false;
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Study flashcards', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  children: [
                    StudySessionHeader(
                      shuffleOn: _shuffleOn,
                      bookmarked: _bookmarked,
                      onShuffleTap: () =>
                          setState(() => _shuffleOn = !_shuffleOn),
                      onBookmarkTap: () =>
                          setState(() => _bookmarked = !_bookmarked),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: _QuestionCard(onTap: _showAnswer)),
                    const SizedBox(height: 10),
                    StudyCardNavigation(
                      // TODO(backend): move between cards in the deck.
                      onPrevious: () {},
                      onNext: () {},
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        'Reveal the answer before rating this card.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          height: 18 / 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    FilledButton(
                      onPressed: _showAnswer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Show Answer'),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            'assets/icons/figma/arrow_right.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
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

  void _showAnswer() => context.push(AppRoutes.cardBack);
}

/// The white question card: "QUESTION · 04 / 20", the question text and
/// the "Tap card to reveal" hint.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'QUESTION',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text('04 / 20', style: AppTextStyles.caption),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'What is the basic unit of life?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/rotate_3d.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap card to reveal',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      height: 18 / 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

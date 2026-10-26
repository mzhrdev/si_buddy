import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_card_navigation.dart';
import '../widgets/study_session_header.dart';

/// Study card back (answer face), implemented from the Figma frame
/// "SI Buddy · Study Card Back" (5:2624).
class StudyCardBackScreen extends StatefulWidget {
  const StudyCardBackScreen({super.key});

  @override
  State<StudyCardBackScreen> createState() => _StudyCardBackScreenState();
}

class _StudyCardBackScreenState extends State<StudyCardBackScreen> {
  bool _shuffleOn = false;
  bool _bookmarked = false;
  String? _rating;

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
                    const Expanded(child: _AnswerCard()),
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
                        'How well did you know it? Choose a rating.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          height: 18 / 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                            child: _RatingOption(
                              label: 'Easy',
                              sublabel: 'Mastered',
                              selected: _rating == 'Easy',
                              onTap: () => _selectRating('Easy'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RatingOption(
                              label: 'Medium',
                              sublabel: 'Learning',
                              selected: _rating == 'Medium',
                              onTap: () => _selectRating('Medium'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RatingOption(
                              label: 'Hard',
                              sublabel: 'Difficult',
                              selected: _rating == 'Hard',
                              onTap: () => _selectRating('Hard'),
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

  void _selectRating(String rating) {
    // TODO(backend): persist the rating and advance the session.
    setState(() => _rating = rating);
  }
}

/// The white answer card: "ANSWER · 04 / 20", the question, the answer
/// with its explanation, the source line and "Show question".
class _AnswerCard extends StatelessWidget {
  const _AnswerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ANSWER',
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
          Text(
            'What is the basic unit of life?',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'The cell.',
            style: AppTextStyles.display.copyWith(
              fontSize: 28,
              height: 34 / 28,
              letterSpacing: -0.56,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Each cell contains structures that work together to support its functions.',
            style: AppTextStyles.muted.copyWith(height: 20 / 13),
          ),
          const Spacer(),
          Text(
            'Source: Cell Biology - Chapter 4.pdf · p. 1',
            style: AppTextStyles.badge.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 9),
          InkWell(
            // TODO(backend): flip back to the question face.
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/figma/rotate_ccw.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text('Show question', style: AppTextStyles.link),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One self-rating option (Easy / Medium / Hard) with its outcome label.
class _RatingOption extends StatelessWidget {
  const _RatingOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sublabel,
              style: AppTextStyles.badge.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

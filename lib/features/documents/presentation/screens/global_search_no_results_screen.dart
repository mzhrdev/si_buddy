import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/global_search_field.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/note_sheet_illustration.dart';
import '../widgets/privacy_reassurance.dart';

/// Global search with no matches, implemented from the Figma frame
/// "SI Buddy · Global Search — No Results" (4:11938). "Clear search"
/// and the suggestion chips update the query field locally.
class GlobalSearchNoResultsScreen extends StatefulWidget {
  const GlobalSearchNoResultsScreen({super.key});

  @override
  State<GlobalSearchNoResultsScreen> createState() =>
      _GlobalSearchNoResultsScreenState();
}

class _GlobalSearchNoResultsScreenState
    extends State<GlobalSearchNoResultsScreen> {
  final _controller = TextEditingController(text: 'medieval astronomy');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Search', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalSearchField(
                          controller: _controller,
                          focused: true,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All documents, flashcards, quizzes & summaries',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const NoteSheetIllustration(
                          badgeIconAsset: 'assets/icons/figma/search_x.svg',
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No matches just yet.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            letterSpacing: -0.48,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nothing found for “medieval astronomy”. Try a '
                          'shorter keyword or check the spelling.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                            height: 22 / 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ImportPrimaryButton(
                          label: 'Clear search',
                          onPressed: () => _controller.clear(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Try something in your library',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SuggestionChip(
                              label: 'Cell',
                              onTap: () => _controller.text = 'Cell',
                            ),
                            const SizedBox(width: 8),
                            _SuggestionChip(
                              label: 'Chemistry',
                              onTap: () => _controller.text = 'Chemistry',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const PrivacyReassurance(
                      text: 'Search only looks at notes on this device.',
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

/// Suggestion chip under "Try something in your library": a 34px white
/// bordered chip with a search icon and muted label.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/figma/search.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

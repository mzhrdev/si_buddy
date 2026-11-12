import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../settings/presentation/providers/storage_providers.dart';
import '../../../settings/presentation/widgets/confirmation_dialog.dart';

/// Section title (14, SemiBold, lh 20).
TextStyle _sectionTitleStyle(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 20 / 14,
  color: context.appText,
);

/// Body copy on this screen (13, Regular, muted, lh 20).
TextStyle _bodyMutedStyle(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 20 / 13,
  color: context.appMuted,
);

/// Privacy, implemented from the Figma frame "SI Buddy · Privacy"
/// (5:20931).
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Privacy', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
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
                              'assets/icons/figma/shield_check.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                context.appPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your notes stay on your device',
                              style: _sectionTitleStyle(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Document reading and text extraction happen '
                          'locally. With Gemma 3 1B IT installed, AI '
                          'study-material generation also runs on your '
                          'device.',
                          style: _bodyMutedStyle(context),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No account needed.',
                          style: AppTextStyles.link(
                            context,
                          ).copyWith(height: 16 / 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'When internet is needed',
                    style: _sectionTitleStyle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The initial model download and any re-download need '
                    'internet, as do Google Play purchases and restoring '
                    'purchases.',
                    style: _bodyMutedStyle(context),
                  ),
                  const SizedBox(height: 16),
                  Text('Policies', style: _sectionTitleStyle(context)),
                  const SizedBox(height: 8),
                  // TODO(backend): open the hosted policy pages.
                  const _PolicyRow(label: 'Privacy Policy'),
                  const _PolicyRow(label: 'Terms'),
                  const SizedBox(height: 16),
                  Text('Data management', style: _sectionTitleStyle(context)),
                  const SizedBox(height: 8),
                  Text(
                    'Clear documents, extracted text, study materials, '
                    'progress, preferences and the downloaded model from '
                    'this app.',
                    style: _bodyMutedStyle(context),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: context.appDangerSurface,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: () => _confirmClearAllData(context, ref),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/trash_2.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                context.appDanger,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear All Local Data',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                color: context.appDanger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This cannot be undone. External exported copies are '
                    'not removed. An active Google Play subscription is '
                    'not cancelled.',
                    style: AppTextStyles.greeting(
                      context,
                    ).copyWith(height: 18 / 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Wipes all local data behind the Figma confirmation dialog,
  /// then returns to Home (which shows the empty state on wiped
  /// data) and reports what happened.
  Future<void> _confirmClearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/icons/figma/trash_2.svg',
      indicatorColor: context.appDangerSurface,
      iconColor: context.appDanger,
      title: 'Clear All Local Data?',
      messageParagraphs: const [
        'Permanently deletes all documents, extracted text, study '
            'materials, progress, preferences and the downloaded model '
            'from SI Buddy.',
        'This cannot be undone.',
        'To generate new study material afterward, you must download '
            'the model again using the internet.',
        'This does not cancel an active Google Play subscription or '
            'remove exported copies outside the app.',
      ],
      emphasizedParagraphs: const {1},
      confirmLabel: 'Clear All Local Data',
      confirmColor: AppColors.danger,
    );
    if (!confirmed) return;
    await clearAllLocalData(ref);
    if (context.mounted) {
      // The SnackBar belongs to the app-root messenger, so it
      // survives the navigation to Home.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All local data cleared.')));
      context.go(AppRoutes.home);
    }
  }
}

/// A policy row: semibold label with an external-link arrow and a
/// bottom border, as in the Figma "Policies" section.
class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _sectionTitleStyle(context))),
          SvgPicture.asset(
            'assets/icons/figma/arrow_up_right.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

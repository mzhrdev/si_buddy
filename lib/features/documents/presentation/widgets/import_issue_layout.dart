import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import 'import_action_buttons.dart';
import 'privacy_reassurance.dart';
import 'state_message.dart';

/// Shared layout for the import error screens (unsupported file,
/// corrupted document, unreadable text, scanned PDF, low storage):
/// the selected-document card, a haloed state icon, headline copy, a
/// white recovery-guidance card, then primary/secondary actions and
/// the privacy reassurance pinned to the bottom.
class ImportIssueLayout extends StatelessWidget {
  const ImportIssueLayout({
    required this.documentCard,
    required this.iconAsset,
    required this.iconColor,
    required this.surfaceColor,
    required this.headline,
    required this.body,
    required this.guidance,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    super.key,
  });

  final Widget documentCard;
  final String iconAsset;
  final Color iconColor;

  /// Background of the 72px icon chip (Figma "Symbol surface").
  final Color surfaceColor;
  final String headline;
  final String body;
  final Widget guidance;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Import notes', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        documentCard,
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 116,
                          child: Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SvgPicture.asset(
                                iconAsset,
                                width: 32,
                                height: 32,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StateMessage(headline: headline, body: body),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: guidance,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ImportPrimaryButton(
                          label: primaryLabel,
                          onPressed: onPrimary,
                        ),
                        const SizedBox(height: 10),
                        ImportSecondaryButton(
                          label: secondaryLabel,
                          onPressed: onSecondary,
                        ),
                        const SizedBox(height: 16),
                        const PrivacyReassurance(
                          text: 'Your notes stay on your device.',
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

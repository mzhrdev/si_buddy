import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_status_header.dart';

/// Restore Purchases, implemented from the Figma frame
/// "SI Buddy · Restore Purchases" (5:24192).
class RestorePurchasesScreen extends StatelessWidget {
  const RestorePurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Restore Purchases', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  const SubscriptionStatusHeader(
                    iconAsset: 'assets/icons/figma/rotate_ccw.svg',
                    iconColor: AppColors.primary,
                    chipColor: AppColors.surface,
                    title: 'Find your Premium purchase',
                    body:
                        'Check Google Play for an existing SI Buddy subscription. Restoring does not start a new purchase.',
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Before you restore',
                    largeParagraphs: true,
                    paragraphs: [
                      'Use the same Google Play account used for the original purchase. No SI Buddy account or sign-in is needed.',
                      'Connect to the internet. Google Play must verify your subscription before access can be restored.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _RestoreStatusCard(),
                  const SizedBox(height: 12),
                  const OfflineStudyGuidance(),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Restore Purchases',
              // TODO(backend): request verification from Google Play.
              onPrimary: () {},
              secondaryLabel: 'Continue with Free',
              onSecondary: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

/// The not-started restore result card.
class _RestoreStatusCard extends StatelessWidget {
  const _RestoreStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Ready to check · Not started',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 18 / 13,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'No purchase has been checked yet. Tap Restore Purchases to request verification. Your result will appear here.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

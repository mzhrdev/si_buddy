import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_status_header.dart';

/// Payment Processing, implemented from the Figma frame
/// "SI Buddy · Payment Processing" (5:24026).
class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Payment Processing', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  const SubscriptionStatusHeader(
                    iconAsset: 'assets/icons/figma/loader_circle.svg',
                    iconColor: AppColors.primary,
                    chipColor: AppColors.surface,
                    title: 'Verifying your purchase',
                    body:
                        'Waiting for Google Play to verify the payment. Premium will activate only after confirmation.',
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionPlanCard(
                    eyebrow: 'Awaiting verification · Sample',
                  ),
                  const SizedBox(height: 12),
                  const _VerificationCard(),
                  const SizedBox(height: 12),
                  const OfflineStudyGuidance(),
                ],
              ),
            ),
            SubscriptionActions(
              note:
                  'Verification needs internet. Do not start another purchase while this one is pending.',
              secondaryLabel: 'Check Purchase / Restore',
              onSecondary: () => context.push(AppRoutes.restore),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pending-verification card: pending dot, status title and body.
class _VerificationCard extends StatelessWidget {
  const _VerificationCard();

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
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Google Play verification pending',
                  style: AppTextStyles.itemTitle.copyWith(height: 18 / 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Keep your internet connection on and allow a moment. If this takes longer, check the purchase in Google Play or use Restore Purchases.',
            style: const TextStyle(
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_entry_row.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_status_header.dart';

/// Payment Failure, implemented from the Figma frame
/// "SI Buddy · Payment Failure" (5:24139).
class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Payment Failure', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  const SubscriptionStatusHeader(
                    iconAsset: 'assets/icons/figma/circle_alert.svg',
                    iconColor: AppColors.danger,
                    chipColor: AppColors.dangerSurface,
                    title: 'Purchase not confirmed',
                    body:
                        'We couldn’t confirm your purchase with Google Play. Premium has not been activated.',
                  ),
                  const SizedBox(height: 12),
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
                        Text(
                          'Check your connection',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Connect to the internet and make sure Google Play is available. Retry only if Google Play shows no completed or pending purchase.',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Already approved the payment?',
                    largeParagraphs: true,
                    paragraphs: [
                      'Check your purchase status in Google Play first. If it appears completed or pending, don’t buy again. Use Restore Purchases to check access with the same Google Play account.',
                    ],
                  ),
                  const SizedBox(height: 8),
                  SubscriptionEntryRow(
                    label: 'Check Purchase / Restore Purchases',
                    onTap: () => context.push(AppRoutes.restore),
                  ),
                  const SizedBox(height: 12),
                  const OfflineStudyGuidance(),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Retry',
              onPrimary: () => context.push(AppRoutes.processing),
              secondaryLabel: 'Return to Free',
              onSecondary: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

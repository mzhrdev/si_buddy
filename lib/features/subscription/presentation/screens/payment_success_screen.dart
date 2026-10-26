import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_status_header.dart';

/// Payment Success, implemented from the Figma frame
/// "SI Buddy · Payment Success" (5:24080).
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Payment Success', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  const SubscriptionStatusHeader(
                    iconAsset: 'assets/icons/figma/circle_check.svg',
                    iconColor: AppColors.primary,
                    chipColor: AppColors.surface,
                    title: 'Your Premium is ready',
                    body:
                        'Purchase confirmed by Google Play in this illustrative flow. Your Annual Premium plan is now active.',
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionPlanCard(eyebrow: 'Active plan · Sample'),
                  const SizedBox(height: 12),
                  const SubscriptionDetailCard(
                    rows: [
                      SubscriptionDetailRow(
                        label: 'Payment confirmed',
                        value: 'US\$39.99',
                      ),
                      SubscriptionDetailRow(
                        label: 'Next renewal',
                        value: '[Renewal date]',
                      ),
                    ],
                    footnote:
                        'Renews at US\$39.99/year unless changed. Manage or cancel in Google Play before renewal to stop future charges.',
                  ),
                  const SizedBox(height: 12),
                  const OfflineStudyGuidance(),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Continue Studying',
              onPrimary: () => context.go(AppRoutes.home),
              secondaryLabel: 'Manage Subscription',
              onSecondary: () => context.push(AppRoutes.manage),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_plan_card.dart';

/// Purchase Confirmation, implemented from the Figma frame
/// "SI Buddy · Purchase Confirmation" (5:23961).
class PurchaseConfirmationScreen extends StatelessWidget {
  const PurchaseConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Purchase Confirmation',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  Text('Review your plan', style: AppTextStyles.display),
                  const SizedBox(height: 6),
                  Text(
                    'Illustrative purchase · No real payment is made.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionPlanCard(eyebrow: 'Selected plan · Sample'),
                  const SizedBox(height: 12),
                  const SubscriptionDetailCard(
                    rows: [
                      SubscriptionDetailRow(
                        label: 'Total charge now',
                        value: 'US\$39.99',
                      ),
                      SubscriptionDetailRow(
                        label: 'Charged every',
                        value: 'Year',
                      ),
                      SubscriptionDetailRow(
                        label: 'Payment method',
                        value: 'Google Play Billing',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Your subscription terms',
                    largeParagraphs: true,
                    paragraphs: [
                      'Renews at US\$39.99/year unless changed. Cancel through Google Play before renewal to stop future charges. Access lasts until the paid period ends, where applicable.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Continue securely with Google Play',
                    largeParagraphs: true,
                    paragraphs: [
                      'Confirm Purchase continues to Google Play Billing and requires internet. SI Buddy never asks for raw card details.',
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        // TODO(backend): open the Terms page.
                        onTap: () {},
                        child: Text('Terms ↗', style: _policyLinkStyle),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        // TODO(backend): open the Privacy Policy page.
                        onTap: () {},
                        child: Text(
                          'Privacy Policy ↗',
                          style: _policyLinkStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Confirm Purchase',
              onPrimary: () => context.push(AppRoutes.processing),
              secondaryLabel: 'Back to Plans',
              onSecondary: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  static const _policyLinkStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: AppColors.primary,
  );
}

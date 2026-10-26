import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_entry_row.dart';
import '../widgets/subscription_guidance.dart';
import '../widgets/subscription_plan_card.dart';

/// Manage Subscription, implemented from the Figma frame
/// "SI Buddy · Manage Subscription" (5:24243).
class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Manage Subscription',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  const Text(
                    'Example active subscription · Editable sample terms',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 18 / 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionPlanCard(eyebrow: 'Active plan · Sample'),
                  const SizedBox(height: 12),
                  const SubscriptionDetailCard(
                    rows: [
                      SubscriptionDetailRow(
                        label: 'Renews on',
                        value: '[Renewal date]',
                      ),
                      SubscriptionDetailRow(
                        label: 'Renewal charge',
                        value: 'US\$39.99 / year',
                      ),
                      SubscriptionDetailRow(
                        label: 'Billed through',
                        value: 'Google Play',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Manage or cancel in Google Play',
                    largeParagraphs: true,
                    paragraphs: [
                      'Internet is required to manage your subscription. It renews at the same rate and frequency unless changed.',
                      'Cancellation stops future renewal. Premium access lasts until the paid period ends, where applicable. Saved materials stay available on Free within its limits.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SubscriptionGuidanceSection(
                    title: 'Your data and billing are separate',
                    largeParagraphs: true,
                    paragraphs: [
                      'Clearing local data or deleting the AI model does not cancel your Google Play subscription.',
                    ],
                  ),
                  const SizedBox(height: 8),
                  SubscriptionEntryRow(
                    label: 'Restore Purchases',
                    onTap: () => context.push(AppRoutes.restore),
                  ),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Manage in Google Play',
              // TODO(backend): open the Google Play subscription page.
              onPrimary: () {},
              secondaryLabel: 'Continue Studying',
              onSecondary: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

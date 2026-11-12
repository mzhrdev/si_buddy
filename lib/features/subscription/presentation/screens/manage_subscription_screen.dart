import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/subscription_entry_row.dart';

/// Manage Subscription, implemented from the Figma frame
/// "SI Buddy · Manage Subscription" (5:24243).
///
/// There is no subscription backend (no Play Billing), so there is
/// no active subscription to manage. The screen says so honestly —
/// Free plan, with a way to see Premium and to restore purchases —
/// instead of the design's sample active plan with a placeholder
/// renewal date and charge.
class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Manage Subscription',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  const EmptyState(
                    icon: Icons.workspace_premium_outlined,
                    title: 'No active subscription',
                    message:
                        'You’re on the Free plan. Premium isn’t available to buy yet — subscriptions arrive with billing.',
                  ),
                  const SizedBox(height: 16),
                  SubscriptionEntryRow(
                    label: 'See Premium',
                    onTap: () => context.push(AppRoutes.premium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

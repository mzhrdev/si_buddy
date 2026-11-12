import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../settings/presentation/widgets/confirmation_dialog.dart';
import '../widgets/subscription_actions.dart';
import '../widgets/subscription_guidance.dart';

/// Upgrade to Premium, implemented from the Figma frame
/// "SI Buddy · Upgrade to Premium" (5:23885).
///
/// Free/Premium comparison and Monthly/Annual plan selection
/// (Annual is selected in the design), with the sample-terms
/// guidance copy. There is no billing backend, so the plans are a
/// preview only and buying is honestly unavailable: the primary
/// button says so in a dialog instead of leading into a purchase
/// flow that cannot complete (the old flow dead-ended at a fake
/// "verification pending" screen).
class UpgradePremiumScreen extends StatefulWidget {
  const UpgradePremiumScreen({super.key});

  @override
  State<UpgradePremiumScreen> createState() => _UpgradePremiumScreenState();
}

class _UpgradePremiumScreenState extends State<UpgradePremiumScreen> {
  static const _plans = [
    (name: 'Monthly', price: 'US\$4.99/month'),
    (name: 'Annual', price: 'US\$39.99/year'),
  ];

  /// The design shows Annual selected.
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Upgrade to Premium', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  Text(
                    'More room for your study routine.',
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Preview only · Editable sample prices and daily limits, not live commercial terms.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 18 / 12,
                      color: context.appMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _ComparisonCard(),
                  const SizedBox(height: 10),
                  Text(
                    'One run = one request to generate flashcards, a quiz or a summary. Offline generation counts toward the daily limit in this sample policy.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 18 / 12,
                      color: context.appMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _plans.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _PlanOption(
                            name: _plans[i].name,
                            price: _plans[i].price,
                            selected: _selectedPlan == i,
                            onTap: () => setState(() => _selectedPlan = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Both plans include the same Premium benefits. Annual renews at US\$39.99/year unless changed.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 18 / 12,
                      color: context.appMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SubscriptionGuidanceSection(
                    title: 'Keep studying on Free, online or offline',
                    titleStyle: AppTextStyles.itemTitle(
                      context,
                    ).copyWith(height: 18 / 13),
                    paragraphs: const [
                      'Saved documents, flashcards, quizzes and summaries stay available within plan limits. Local AI needs an installed model and sufficient memory and storage.',
                      'Internet is required for Google Play purchases, restore, verification, subscription management and model downloads. Premium does not install the model.',
                    ],
                  ),
                ],
              ),
            ),
            SubscriptionActions(
              primaryLabel: 'Continue with ${_plans[_selectedPlan].name}',
              onPrimary: () => _showPremiumUnavailable(context),
              footer: GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Text(
                  'Continue with Free',
                  style: _footerLinkStyle(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Premium cannot be bought in this version — there is no billing
  /// backend. Say so plainly instead of starting a purchase that
  /// cannot complete.
  Future<void> _showPremiumUnavailable(BuildContext context) async {
    final goFree = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/icons/figma/subscription.svg',
      indicatorColor: context.appSurface,
      iconColor: context.appPrimary,
      title: 'Premium isn’t available yet',
      messageParagraphs: const [
        'Subscriptions arrive with billing — there is nothing to buy in this version, and no payment is taken.',
        'Everything you have stays available on the Free plan.',
      ],
      confirmLabel: 'Continue with Free',
    );
    if (goFree && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  static TextStyle _footerLinkStyle(BuildContext context) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    color: context.appPrimary,
  );
}

/// The Free vs Premium feature comparison card (columns 88 / 87 / rest).
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  static const _rows = [
    ('AI generation', '3 runs/day', '30 runs/day'),
    ('Customization', 'Basic controls', 'Advanced controls'),
    ('Statistics', 'Basic + latest quiz', 'Detailed topic trends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  'Included',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 18 / 12,
                    color: context.appMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 87,
                child: Text('Free', style: AppTextStyles.itemTitle(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Premium',
                  style: AppTextStyles.itemTitle(
                    context,
                  ).copyWith(color: context.appPrimary),
                ),
              ),
            ],
          ),
          for (final row in _rows) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 88,
                  child: Text(row.$1, style: _cellStyle(context.appText)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 87,
                  child: Text(row.$2, style: _cellStyle(context.appMuted)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.$3,
                    style: _cellStyle(
                      context.appPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static TextStyle _cellStyle(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: color,
  );
}

/// One selectable billing plan card; the selected plan uses the
/// surface-selected fill and a 2px primary border.
class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.name,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? context.appSurface : context.appCard,
          border: Border.all(
            color: selected ? context.appPrimary : context.appBorder,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTextStyles.itemTitle(context)),
                SvgPicture.asset(
                  selected
                      ? 'assets/icons/figma/radio_button_selected.svg'
                      : 'assets/icons/figma/radio_button.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    selected ? context.appPrimary : context.appNavInactive,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(price, style: AppTextStyles.title(context)),
            const SizedBox(height: 6),
            Text('All Premium benefits', style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }
}

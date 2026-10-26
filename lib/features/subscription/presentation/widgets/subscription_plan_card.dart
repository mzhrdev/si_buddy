import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The "SI Buddy Premium · Annual" plan card shared by the purchase,
/// processing, success and manage frames: an eyebrow label, the plan
/// name, the billing row and the benefits line.
class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({required this.eyebrow, super.key});

  /// e.g. "Selected plan · Sample", "Active plan · Sample".
  final String eyebrow;

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
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text('SI Buddy Premium · Annual', style: AppTextStyles.screenTitle),
          const SizedBox(height: 10),
          const SubscriptionDetailRow(
            label: 'Billing',
            value: 'US\$39.99 / year',
          ),
          const SizedBox(height: 10),
          Text(
            '30 AI runs/day, advanced customization and detailed topic analytics.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 18 / 12,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One label/value row inside a subscription card: muted 12px label on
/// the left, semibold 13px value on the right.
class SubscriptionDetailRow extends StatelessWidget {
  const SubscriptionDetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 18 / 12,
              color: AppColors.muted,
            ),
          ),
        ),
        Text(value, style: AppTextStyles.itemTitle),
      ],
    );
  }
}

/// White bordered card holding a stack of [SubscriptionDetailRow]s, with
/// an optional muted footnote under the rows.
class SubscriptionDetailCard extends StatelessWidget {
  const SubscriptionDetailCard({required this.rows, this.footnote, super.key});

  final List<SubscriptionDetailRow> rows;
  final String? footnote;

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
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            rows[i],
          ],
          if (footnote != null) ...[
            const SizedBox(height: 10),
            Text(
              footnote!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 18 / 12,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

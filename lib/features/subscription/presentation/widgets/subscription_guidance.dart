import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// A titled guidance section (semibold heading + muted paragraphs) used
/// for the terms copy block on the Upgrade to Premium frame.
class SubscriptionGuidanceSection extends StatelessWidget {
  const SubscriptionGuidanceSection({
    required this.title,
    required this.paragraphs,
    this.largeParagraphs = false,
    this.titleStyle,
    super.key,
  });

  final String title;
  final List<String> paragraphs;

  /// Paragraphs are 12/18 by default; the terms-style sections use
  /// 13/20 body copy instead.
  final bool largeParagraphs;

  /// Overrides the default 14px semibold section title.
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final paragraphStyle = largeParagraphs
        ? TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: context.appMuted,
          )
        : TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
            color: context.appMuted,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              AppTextStyles.body(
                context,
              ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
        ),
        for (final paragraph in paragraphs) ...[
          const SizedBox(height: 6),
          Text(paragraph, style: paragraphStyle),
        ],
      ],
    );
  }
}

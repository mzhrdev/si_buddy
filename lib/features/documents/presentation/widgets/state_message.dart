import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Headline + supporting copy block used at the top of the document
/// import screens (Figma "State message": 28px bold headline with
/// -0.56 tracking, 14px muted body).
class StateMessage extends StatelessWidget {
  const StateMessage({
    required this.headline,
    required this.body,
    this.centered = false,
    super.key,
  });

  final String headline;
  final String body;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    final cross = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          headline,
          textAlign: align,
          style: AppTextStyles.display.copyWith(
            fontSize: 28,
            height: 34 / 28,
            letterSpacing: -0.56,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: align,
          style: AppTextStyles.body.copyWith(
            color: AppColors.muted,
            height: 22 / 14,
          ),
        ),
      ],
    );
  }
}

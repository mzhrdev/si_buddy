import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

/// Section heading used across the Study screens: a 16px semibold
/// title with a trailing primary text action, e.g.
/// "Folders — + New folder".
class StudySectionHeading extends StatelessWidget {
  const StudySectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel, style: AppTextStyles.link),
        ),
      ],
    );
  }
}

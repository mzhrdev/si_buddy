import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// The 64px screen header used across the app.
///
/// Two forms:
/// - Tab roots (no [onBack]): title on the left.
/// - Sub-screens ([onBack] given): back button on the left and title.
///
/// Text-only: no divider, no shadow, no brand mark — the title in
/// [AppTextStyles.screenTitle] carries the header.
class AppHeader extends StatelessWidget {
  const AppHeader({required this.title, this.onBack, this.trailing, super.key});

  final String title;

  /// When null, the header uses the tab-root form.
  final VoidCallback? onBack;

  /// Optional widget shown at the right edge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.only(left: onBack == null ? 24 : 8, right: 24),
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back, size: 22),
                color: context.appText,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                padding: EdgeInsets.zero,
              ),
            Expanded(
              child: Text(title, style: AppTextStyles.screenTitle(context)),
            ),
            // Zero-size when no trailing is given (the linter flags
            // both `if (trailing != null) trailing!` and the
            // `case final trailing?` pattern here).
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../layout/responsive_spacing.dart';

/// A centered honest empty state: a small ink glyph naming what is
/// missing, a title, a short explanation, and an optional primary
/// action. No tinted surface, no circle, no border — on the screen's
/// flat background.
///
/// Used wherever a screen has no real data to show — no sample
/// content is ever rendered in its place.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// The glyph shown above the title (a Material icon — no asset
  /// dependency, so this can never fail to load). Small and ink:
  /// it names what is missing, it is not decoration.
  final IconData icon;

  /// Short heading, e.g. 'No flashcards yet'.
  final String title;

  /// One or two sentences explaining why the screen is empty and
  /// what to do next.
  final String message;

  /// Label for the primary action button; hidden when null.
  final String? actionLabel;

  /// What the primary action does; hidden when null.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.horizontal(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: context.appMuted),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.screenTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.muted(context),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

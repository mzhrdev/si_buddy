import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';

/// Clear Cache confirmation, implemented from the Figma frame
/// "SI Buddy · Clear Cache Confirmation" (5:21106) — a confirmation
/// dialog overlaid on the Storage screen.
class ClearCacheConfirmationScreen extends StatelessWidget {
  const ClearCacheConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      iconAsset: 'assets/icons/figma/eraser.svg',
      indicatorColor: AppColors.surface,
      iconColor: AppColors.primary,
      title: 'Clear Cache?',
      messageParagraphs: const [
        'Only temporary cache is removed. It may be rebuilt as you use '
            'the app.',
        'Your source documents, extracted text, downloaded model, study '
            'sets and study progress are preserved.',
      ],
      confirmLabel: 'Clear Cache',
      // TODO(backend): clear the temporary cache, then return.
      onConfirm: () => context.pop(),
      onCancel: () => context.pop(),
    );
  }
}

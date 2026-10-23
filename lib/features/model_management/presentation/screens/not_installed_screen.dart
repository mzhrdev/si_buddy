import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Not Installed, implemented from the Figma frame
/// "SI Buddy · AI Model — Not Installed" (5:15053).
class ModelNotInstalledScreen extends StatelessWidget {
  const ModelNotInstalledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'Not installed',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/download_plain.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Download once. Generate offline.',
      readinessBody:
          'The initial model download requires internet. AI generation is unavailable until installation completes.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Download Model',
      onPrimary: () => context.push(AppRoutes.downloading),
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
    );
  }
}

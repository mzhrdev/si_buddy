import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Ready Offline, implemented from the Figma frame
/// "SI Buddy · AI Model — Ready Offline" (5:15211).
class ReadyOfflineScreen extends StatelessWidget {
  const ReadyOfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'AI Ready Offline',
      statusColor: AppColors.successText,
      readinessIconAsset: 'assets/icons/figma/circle_check_outline.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Installed and ready for offline AI',
      readinessBody:
          'Installation successful. Local generation works offline when enough device memory and storage are available.',
      generationAvailability: 'Works offline with sufficient device resources.',
      primaryLabel: 'Continue Studying',
      onPrimary: () => context.go(AppRoutes.home),
      secondaryLabel: 'Delete Model',
      onSecondary: () => context.push(AppRoutes.deleteModel),
      secondaryColor: AppColors.danger,
      secondaryBorderColor: AppColors.danger,
    );
  }
}

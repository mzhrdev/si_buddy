import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Low Memory, implemented from the Figma frame
/// "SI Buddy · AI Model — Low Memory" (5:15363).
class ModelLowMemoryScreen extends StatelessWidget {
  const ModelLowMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'Installed · Low memory',
      statusColor: AppColors.danger,
      readinessBackground: AppColors.dangerSurface,
      readinessIconAsset: 'assets/icons/figma/circle_alert.svg',
      readinessIconColor: AppColors.danger,
      readinessTitle: 'Not enough free memory',
      readinessBody:
          'Generation is temporarily unavailable. Close other apps or reduce generation size, then check again.',
      generationAvailability:
          'Model installed; waiting for enough free resources.',
      primaryLabel: 'Check Again',
      // TODO(backend): re-check free device memory.
      onPrimary: () {},
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
    );
  }
}

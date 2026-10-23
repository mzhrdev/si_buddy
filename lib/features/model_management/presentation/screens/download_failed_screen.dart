import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Download Failed, implemented from the Figma frame
/// "SI Buddy · AI Model — Download Failed" (5:15287).
class ModelDownloadFailedScreen extends StatelessWidget {
  const ModelDownloadFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'Download failed · Not installed',
      statusColor: AppColors.danger,
      readinessBackground: AppColors.dangerSurface,
      readinessIconAsset: 'assets/icons/figma/circle_alert.svg',
      readinessIconColor: AppColors.danger,
      readinessTitle: 'Model download interrupted',
      readinessBody:
          'The internet connection was lost. The model is not installed. Reconnect to the internet and try again.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Retry',
      onPrimary: () => context.push(AppRoutes.downloading),
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Downloading, implemented from the Figma frame
/// "SI Buddy · AI Model — Downloading" (5:15129).
class ModelDownloadingScreen extends StatelessWidget {
  const ModelDownloadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'Downloading · Not installed',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/download_plain.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Downloading model…',
      readinessBody:
          'Keep your internet connection on. AI generation becomes available only after installation completes.',
      readinessChild: const ModelDownloadProgress(),
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Cancel Download',
      onPrimary: () => context.push(AppRoutes.notInstalled),
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
    );
  }
}

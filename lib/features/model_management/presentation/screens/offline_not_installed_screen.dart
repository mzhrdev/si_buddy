import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Offline / Not Installed, implemented from the Figma frame
/// "SI Buddy · AI Model — Offline / Not Installed" (5:15439).
class OfflineNotInstalledScreen extends StatelessWidget {
  const OfflineNotInstalledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModelManagementLayout(
      statusLabel: 'Not installed · Offline',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/wifi_off.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Connect to download the model',
      readinessBody:
          'You’re offline, so the download can’t start. Connect to the internet to download and install the model.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Retry Connection',
      // TODO(backend): re-check connectivity, then start the download.
      onPrimary: () {},
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
    );
  }
}

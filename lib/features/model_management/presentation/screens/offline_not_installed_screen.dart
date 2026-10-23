import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Offline / Not Installed, implemented from the Figma frame
/// "SI Buddy · AI Model — Offline / Not Installed" (5:15439).
///
/// "Retry Connection" starts the download and shows its progress:
/// if the device is still offline the download fails honestly into
/// the Download Failed state rather than pretending to connect.
class OfflineNotInstalledScreen extends ConsumerWidget {
  const OfflineNotInstalledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModelManagementLayout(
      statusLabel: 'Not installed · Offline',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/wifi_off.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Connect to download the model',
      readinessBody:
          'You\u2019re offline, so the download can\u2019t start. Connect to the internet to download and install the model.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Retry Connection',
      onPrimary: () {
        ref.read(modelProvider.notifier).startDownload();
        context.push(AppRoutes.downloading);
      },
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}

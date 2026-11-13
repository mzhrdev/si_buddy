import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';
import '../../../settings/presentation/widgets/confirmation_dialog.dart';

/// AI Model — the AI service status screen.
///
/// Generation no longer uses an on-device model: it runs through
/// the app's backend proxy (Groq, via the app's own proxy),
/// configured at build time with --dart-define=PROXY_URL /
/// APP_TOKEN. This screen reports whether that service is
/// configured and answers its health probe, offers a Test
/// Connection action, and — where the old model delete lived —
/// removes a legacy downloaded model file, if one is still on
/// this device, to free its storage. Generation never needed
/// that file.
class ApiServiceScreen extends ConsumerStatefulWidget {
  const ApiServiceScreen({super.key});

  @override
  ConsumerState<ApiServiceScreen> createState() => _ApiServiceScreenState();
}

class _ApiServiceScreenState extends ConsumerState<ApiServiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final modelState = ref.watch(modelProvider);
    final status = modelState.status;
    final checking = status == ModelStatus.unknown;
    final ready = status == ModelStatus.ready;
    return ModelManagementLayout(
      statusLabel: switch (status) {
        ModelStatus.ready => 'Connected',
        ModelStatus.notInstalled => 'Not configured',
        ModelStatus.failed => 'Something went wrong',
        ModelStatus.unknown => 'Checking…',
      },
      statusColor: ready
          ? context.appSuccessText
          : status == ModelStatus.failed
          ? context.appDanger
          : context.appPrimary,
      readinessIconAsset: ready
          ? 'assets/svgs/figma/circle_check_outline.svg'
          : status == ModelStatus.failed
          ? 'assets/svgs/figma/circle_alert.svg'
          : 'assets/svgs/figma/wifi_off.svg',
      readinessIconColor: ready
          ? context.appPrimary
          : status == ModelStatus.failed
          ? context.appDanger
          : context.appPrimary,
      readinessBackground: status == ModelStatus.failed
          ? context.appDangerSurface
          : null,
      readinessTitle: switch (status) {
        ModelStatus.ready => 'AI service connected',
        ModelStatus.notInstalled => 'AI service not configured',
        ModelStatus.failed => 'AI service error',
        ModelStatus.unknown => 'Checking the AI service…',
      },
      readinessBody: switch (status) {
        ModelStatus.ready =>
          'Generation uses your online AI service (Groq, via your '
              'own backend). Your extracted text is sent to the '
              'service to generate study material.',
        ModelStatus.notInstalled =>
          'This build has no AI service configured, so generation '
              'is unavailable. Your documents and study sets still '
              'work.',
        ModelStatus.failed =>
          modelState.failure?.message ??
              'Something went wrong with the AI service. Try again.',
        ModelStatus.unknown => 'Probing your AI service…',
      },
      generationAvailability: ready
          ? 'Needs internet. Your notes are sent to your AI service '
                'to generate.'
          : 'Unavailable until the service is configured.',
      primaryLabel: ready ? 'Continue Studying' : 'Test Connection',
      onPrimary: () {
        if (ready) {
          context.go(AppRoutes.home);
        } else {
          ref.read(modelProvider.notifier).refresh();
        }
      },
      secondaryLabel: checking
          ? 'Continue Studying'
          : 'Delete Downloaded Model',
      onSecondary: () {
        if (checking) {
          context.go(AppRoutes.home);
        } else {
          _confirmDeleteModel(context, ref);
        }
      },
      secondaryColor: checking ? null : context.appDanger,
      secondaryBorderColor: checking ? null : context.appDanger,
      modelVersion: AiModelInfo.current.versionLabel,
    );
  }

  /// Deletes a legacy downloaded model file behind a confirmation
  /// dialog (the Figma delete-model confirmation, shown as a
  /// dialog over this screen instead of a separate route). The
  /// file is only the retired on-device model's — generation uses
  /// the online service and never needed it. When no file is left,
  /// the delete is a silent no-op and the screen stays put.
  Future<void> _confirmDeleteModel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/svgs/figma/trash_2.svg',
      indicatorColor: context.appDangerSurface,
      iconColor: context.appDanger,
      title: 'Delete Downloaded Model?',
      messageParagraphs: const [
        'Removes the old on-device model file if one is still on this device (about 343 MB). Your existing documents and study sets stay intact.',
        'Generation uses your online AI service and does not need the file.',
      ],
      confirmLabel: 'Delete Model',
      confirmColor: AppColors.danger,
    );
    if (!confirmed) return;
    await ref.read(modelProvider.notifier).deleteModel();
  }
}

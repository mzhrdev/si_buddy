import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../model_management/domain/model_state.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../../../study/presentation/providers/reminder_providers.dart';
import '../widgets/settings_row.dart';

/// Settings hub, implemented from the Figma frame
/// "SI Buddy · Settings Hub" (5:20615).
///
/// Tab-root screen: the shell provides the bottom navigation and the
/// header uses the brand-lockup form. Every trailing value is real:
/// Reminders from the persisted reminder settings, AI Model from the
/// live model state. There is no Language row (the brief removed the
/// setting) and no Appearance row (the app is Light Mode only since
/// the 2026-11-12 restyle).
class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyOn = ref.watch(dailyReminderEnabledProvider).value ?? false;
    final revisionOn =
        ref.watch(revisionRemindersEnabledProvider).value ?? false;
    final modelState = ref.watch(modelProvider);
    final modelName = AiModelInfo.current.displayName;
    final (modelText, modelRoute) = switch (modelState.status) {
      ModelStatus.ready => ('$modelName · Installed', AppRoutes.readyOffline),
      ModelStatus.downloading => (
        '$modelName · Downloading',
        AppRoutes.downloading,
      ),
      ModelStatus.failed => (
        '$modelName · Download failed',
        AppRoutes.downloadFailed,
      ),
      ModelStatus.notInstalled => (
        '$modelName · Not installed',
        AppRoutes.notInstalled,
      ),
      // Not yet probed this session: the Ready screen probes on
      // open and redirects itself when the probe lands.
      ModelStatus.unknown => ('$modelName · Checking…', AppRoutes.readyOffline),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: ResponsiveSpacing.page(context),
                children: [
                  Text(
                    'Make SI Buddy work for you.',
                    style: AppTextStyles.muted(
                      context,
                    ).copyWith(height: 20 / 13),
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Preferences',
                    children: [
                      SettingsCard(
                        children: [
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/bell.svg',
                            label: 'Reminders',
                            trailingValue: dailyOn || revisionOn ? 'On' : 'Off',
                            onTap: () => context.push(AppRoutes.preferences),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'App & storage',
                    children: [
                      SettingsCard(
                        children: [
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/model.svg',
                            label: 'AI Model',
                            supportingText: modelText,
                            showDivider: true,
                            onTap: () => context.push(modelRoute),
                          ),
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/storage.svg',
                            label: 'Storage',
                            supportingText: 'Manage local files and cache',
                            showDivider: true,
                            onTap: () => context.push(AppRoutes.storage),
                          ),
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/subscription.svg',
                            label: 'Subscription',
                            supportingText: 'Free plan · Premium coming soon',
                            onTap: () => context.push(AppRoutes.premium),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Privacy & support',
                    children: [
                      SettingsRow(
                        iconAsset: 'assets/icons/figma/shield_check.svg',
                        label: 'Privacy',
                        showDivider: true,
                        onTap: () => context.push(AppRoutes.privacy),
                      ),
                      SettingsCard(
                        children: [
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/circle_help.svg',
                            label: 'Help',
                            supportingText: 'Help & About · FAQs and feedback',
                            showDivider: true,
                            onTap: () => context.push(AppRoutes.help),
                          ),
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/info.svg',
                            label: 'About',
                            supportingText: 'Help & About · App and model info',
                            onTap: () => context.push(AppRoutes.help),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/settings_row.dart';

/// Settings hub, implemented from the Figma frame
/// "SI Buddy · Settings Hub" (5:20615).
///
/// Tab-root screen: the shell provides the bottom navigation and the
/// header uses the brand-lockup form.
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Text(
                    'Make SI Buddy work for you.',
                    style: AppTextStyles.muted.copyWith(height: 20 / 13),
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Preferences',
                    children: [
                      SettingsCard(
                        children: [
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/sun_moon.svg',
                            label: 'Appearance',
                            trailingValue: 'System',
                            showDivider: true,
                            onTap: () => context.push(AppRoutes.preferences),
                          ),
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/languages.svg',
                            label: 'Language',
                            trailingValue: 'English',
                            showDivider: true,
                            onTap: () => context.push(AppRoutes.preferences),
                          ),
                          SettingsRow(
                            iconAsset: 'assets/icons/figma/bell.svg',
                            label: 'Reminders',
                            trailingValue: 'Off',
                            showDivider: true,
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
                      SettingsRow(
                        iconAsset: 'assets/icons/figma/model.svg',
                        label: 'AI Model',
                        supportingText: 'Gemma 3 1B IT · AI Ready Offline',
                        onTap: () => context.push(AppRoutes.readyOffline),
                      ),
                      SettingsRow(
                        iconAsset: 'assets/icons/figma/storage.svg',
                        label: 'Storage',
                        supportingText: 'Manage local files and cache',
                        onTap: () => context.push(AppRoutes.storage),
                      ),
                      SettingsRow(
                        iconAsset: 'assets/icons/figma/subscription.svg',
                        label: 'Subscription',
                        supportingText: 'Plans & Google Play purchases',
                        onTap: () => context.push(AppRoutes.premium),
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
                            showDivider: true,
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

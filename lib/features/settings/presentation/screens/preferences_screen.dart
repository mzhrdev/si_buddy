import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_toggle.dart';

/// Note text under sections/cards (12, Regular, muted, lh 18).
const _noteStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 18 / 12,
  color: AppColors.muted,
);

/// Preferences, implemented from the Figma frame
/// "SI Buddy · Preferences" (5:20736).
///
/// Theme single-selection defaults to "System" and both reminder
/// toggles default to off, exactly as designed; all controls work
/// locally with setState.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _themes = ['Light', 'Dark', 'System'];
  int _theme = 2; // "System" is selected in the design.
  bool _dailyReminder = false;
  bool _revisionReminder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Preferences', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  SettingsSection(
                    title: 'Appearance',
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < _themes.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _ThemeOption(
                                label: _themes[i],
                                selected: _theme == i,
                                onTap: () => setState(() => _theme = i),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'System follows your device’s appearance.',
                        style: _noteStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Language',
                    children: [
                      _BorderedCard(
                        children: [
                          Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Generated-content language',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 20 / 14,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                Text('English', style: AppTextStyles.greeting),
                                const SizedBox(width: 4),
                                SvgPicture.asset(
                                  'assets/icons/figma/chevron_right.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.navInactive,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'For new flashcards, quizzes and summaries. '
                            'Existing study materials stay unchanged.',
                            style: _noteStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Study & revision reminders',
                    children: [
                      _BorderedCard(
                        children: [
                          _ReminderRow(
                            title: 'Daily study reminder',
                            supportingText:
                                'Optional · Off · Daily goal: 20 min',
                            value: _dailyReminder,
                            onChanged: (v) =>
                                setState(() => _dailyReminder = v),
                          ),
                          _ReminderRow(
                            title: 'Revision reminder',
                            supportingText: 'Optional · Off · Planned revision',
                            value: _revisionReminder,
                            onChanged: (v) =>
                                setState(() => _revisionReminder = v),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Preferred time',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  height: 20 / 13,
                                  color: AppColors.muted,
                                ),
                              ),
                              // Disabled in the design: no reminder is on.
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '7:00 PM',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 13,
                                        height: 20 / 13,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icons/figma/clock.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.navInactive,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'No reminders are scheduled. Time becomes '
                            'available when a reminder is enabled.',
                            style: _noteStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enabling will ask for Android notification '
                        'permission if needed. Reminders require permission; '
                        'nothing is enabled yet.',
                        style: _noteStyle,
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

/// White card with a border and 14px padding, used by the Language and
/// Reminders sections of the Preferences design.
class _BorderedCard extends StatelessWidget {
  const _BorderedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One theme option in the Appearance single-selection row (76 high).
/// The selected option gets the surface-selected background, a primary
/// border, the filled radio and a semibold primary label.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                selected
                    ? 'assets/icons/figma/radio_button_selected.svg'
                    : 'assets/icons/figma/radio_button.svg',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: selected
                    ? const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 18 / 13,
                        color: AppColors.primary,
                      )
                    : AppTextStyles.body.copyWith(
                        fontSize: 13,
                        height: 20 / 13,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reminder preference row: two-line details plus a toggle.
class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.title,
    required this.supportingText,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String supportingText;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(supportingText, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SettingsToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

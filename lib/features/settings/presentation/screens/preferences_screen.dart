import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../study/presentation/providers/reminder_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_toggle.dart';

/// Note text under sections/cards (12, Regular, muted, lh 18).
TextStyle _noteStyle(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 18 / 12,
  color: context.appMuted,
);

/// Preferences, implemented from the Figma frame
/// "SI Buddy · Preferences" (5:20736).
///
/// The reminder toggles and preferred time are real (Phase 5): they
/// read and write the persisted reminder settings and schedule/cancel
/// actual Android notifications, asking for the notification
/// permission first. There is no Language setting (the brief removed
/// it — generated content is English-only) and no Appearance setting
/// (the app is Light Mode only since the 2026-11-12 restyle).
class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final dailyOn = ref.watch(dailyReminderEnabledProvider).value ?? false;
    final revisionOn =
        ref.watch(revisionRemindersEnabledProvider).value ?? false;
    final timeMinutes =
        ref.watch(reminderTimeMinutesProvider).value ??
        defaultReminderTimeMinutes;
    final goal = ref.watch(dailyGoalMinutesProvider).value ?? 20;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Preferences', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: ResponsiveSpacing.page(context),
                children: [
                  SettingsSection(
                    title: 'Study & revision reminders',
                    children: [
                      _BorderedCard(
                        children: [
                          _ReminderRow(
                            title: 'Daily study reminder',
                            supportingText:
                                'Optional · ${dailyOn ? 'On' : 'Off'} · Daily goal: $goal min',
                            value: dailyOn,
                            onChanged: (v) => _setDaily(context, ref, v),
                          ),
                          _ReminderRow(
                            title: 'Revision reminder',
                            supportingText:
                                'Optional · ${revisionOn ? 'On' : 'Off'} · Planned revision',
                            value: revisionOn,
                            onChanged: (v) => _setRevision(context, ref, v),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Preferred time',
                                style: AppTextStyles.body(context).copyWith(
                                  fontSize: 13,
                                  height: 20 / 13,
                                  color: context.appMuted,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _pickTime(context, ref, timeMinutes),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  // Flat surface chip, not a bordered
                                  // box: this control sits inside the
                                  // bordered reminders card, and nested
                                  // bordered containers are flattened.
                                  decoration: BoxDecoration(
                                    color: context.appSurface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(timeMinutes),
                                        style: AppTextStyles.body(context)
                                            .copyWith(
                                              fontSize: 13,
                                              height: 20 / 13,
                                              color: context.appMuted,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        'assets/icons/figma/clock.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          context.appNavInactive,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dailyOn || revisionOn
                                ? 'Reminders are scheduled. The daily reminder fires at the preferred time; revision reminders fire at each revision’s scheduled time.'
                                : 'No reminders are scheduled. Time becomes available when a reminder is enabled.',
                            style: _noteStyle(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enabling will ask for Android notification '
                        'permission if needed. Reminders require permission; '
                        'if you deny it, the toggle stays off.',
                        style: _noteStyle(context),
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

  /// Enables/disables the daily reminder, asking for the
  /// notification permission first. A denial leaves the toggle off
  /// and explains where to turn notifications on.
  Future<void> _setDaily(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final ok = await setDailyReminderEnabled(ref, enabled);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are off for SI Buddy. Turn them on in Android Settings > Apps > SI Buddy > Notifications to enable reminders.',
          ),
        ),
      );
    }
  }

  Future<void> _setRevision(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final ok = await setRevisionRemindersEnabled(ref, enabled);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are off for SI Buddy. Turn them on in Android Settings > Apps > SI Buddy > Notifications to enable reminders.',
          ),
        ),
      );
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    int currentMinutes,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
    );
    if (picked == null) return;
    await setReminderTimeMinutes(ref, picked.hour * 60 + picked.minute);
  }
}

String _formatTime(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'AM' : 'PM';
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

/// White card with a border and 14px padding, used by the Reminders
/// section of the Preferences design.
class _BorderedCard extends StatelessWidget {
  const _BorderedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            // Rows inside the card are separated by hairlines, not
            // by whitespace gaps.
            if (i > 0) const Divider(height: 20),
            children[i],
          ],
        ],
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(supportingText, style: AppTextStyles.caption(context)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SettingsToggle(value: value, onChanged: onChanged, label: title),
        ],
      ),
    );
  }
}

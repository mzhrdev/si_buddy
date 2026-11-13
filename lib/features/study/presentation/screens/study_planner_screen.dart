import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extensions_kit/extensions_kit.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../domain/study_models.dart';
import '../providers/reminder_providers.dart';
import '../providers/study_providers.dart';
import '../widgets/study_destinations_bar.dart';
import '../widgets/study_progress_track.dart';
import '../widgets/study_section_heading.dart';

/// Study Planner, implemented from the Figma frame
/// "SI Buddy · Study Planner" (5:11948).
///
/// The daily goal is one user-configured number — study time in
/// minutes — tracked from the recorded sessions and resetting at
/// local midnight. Upcoming revisions are the persisted scheduled
/// revisions: they can be added (study set + date + time), edited,
/// completed and deleted, and each one schedules a real Android
/// notification when revision reminders are on. The reminder card
/// wires the revision-reminder toggle and the preferred time to the
/// same persisted settings the Preferences screen uses.
///
/// Nothing here is session-only any more, and no checkbox or
/// counter inflates progress: the bar moves only when a study
/// session ends.
class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(studyStatsProvider).value ?? StudyStats.empty;
    final goal = ref.watch(dailyGoalMinutesProvider).value ?? 20;
    final revisionsAsync = ref.watch(_upcomingRevisionsProvider);
    final decks = ref.watch(decksStreamProvider).value ?? const [];
    final now = DateTime.now();
    final studiedMinutes = stats.studiedTodaySeconds ~/ 60;
    final fraction = goal == 0 ? 0.0 : (studiedMinutes / goal).clamp(0.0, 1.0);
    final goalComplete = goal > 0 && studiedMinutes >= goal;
    // `.value ?? const []` (not a loading spinner): the stream reads
    // the local database, which resolves in milliseconds on a device
    // — but it starts as null, and a spinner here would spin forever
    // in environments where the database never answers (widget
    // tests). The empty state is the honest interim state.
    final revisions = revisionsAsync.value ?? const <RevisionRecord>[];
    final revisionsError = revisionsAsync.hasError;
    final deckTitles = {for (final deck in decks) deck.id: deck.title};
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Study planner'),
            Expanded(
              child: ListView(
                padding: ResponsiveSpacing.page(context, bottom: 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 1),
                  SizedBox(height: context.h(1.9)),
                  StudySectionHeading(
                    title: 'Today, ${now.day} ${_months[now.month - 1]}',
                    actionLabel: 'Edit goal',
                    onAction: () => _editGoal(context, ref, goal),
                  ),
                  SizedBox(height: context.h(.5)),
                  Text(
                    goalComplete ? 'Daily goal reached — nice work.' : 'A little every day adds up.',
                    style: AppTextStyles.greeting(context),
                  ),
                  SizedBox(height: context.h(1.9)),
                  _DailyGoalCard(
                    studiedMinutes: studiedMinutes,
                    goalMinutes: goal,
                    fraction: fraction,
                    complete: goalComplete,
                  ),
                  SizedBox(height: context.h(1.9)),
                  StudySectionHeading(
                    title: 'Upcoming revision',
                    actionLabel: '+ Add',
                    onAction: () => _addRevision(context, ref, decks),
                  ),
                  SizedBox(height: context.h(1.2)),
                  if (revisionsError)
                    const Text('Could not load your revisions.')
                  else if (revisions.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No revisions scheduled yet. Add one to plan your next review.',
                        style: TextStyle(color: context.appMuted),
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (var i = 0; i < revisions.length; i++) ...[
                          if (i > 0) SizedBox(height: context.h(1.2)),
                          _RevisionRow(
                            revision: revisions[i],
                            deckTitle: deckTitles[revisions[i].deckId] ?? 'Study set',
                            onOpen: () => _openRevision(context, ref, revisions[i]),
                            onEdit: () => _editRevision(context, ref, revisions[i], decks),
                            onDelete: () => _deleteRevision(context, ref, revisions[i]),
                            onComplete: () => _completeRevision(context, ref, revisions[i]),
                          ),
                        ],
                      ],
                    ),
                  SizedBox(height: context.h(1.9)),
                  const _ReminderCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref, int currentGoal) async {
    final controller = TextEditingController(text: '$currentGoal');
    String? error;
    final minutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Daily study goal'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Minutes per day', errorText: error, suffixText: 'minutes'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value < 1 || value > 480) {
                  setState(() => error = 'Enter a goal between 1 and 480 minutes.');
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (minutes == null || minutes == currentGoal) return;
    await setDailyGoalMinutes(ref, minutes);
  }

  Future<void> _addRevision(BuildContext context, WidgetRef ref, List<StudyDeck> decks) async {
    final created = await _showRevisionDialog(context, decks: decks, title: 'Add revision');
    if (created == null || !context.mounted) return;
    final repository = ref.read(studyRepositoryProvider);
    final revisionId = await repository.scheduleRevision(
      deckId: created.deckId,
      scheduledAt: created.scheduledAt,
      note: created.note,
    );
    final revision = await repository.watchUpcomingRevisions().first.then(
      (revisions) => revisions.where((r) => r.id == revisionId).firstOrNull,
    );
    if (revision != null) {
      await scheduleRevisionNotification(ref, revision);
    }
  }

  Future<void> _editRevision(
    BuildContext context,
    WidgetRef ref,
    RevisionRecord revision,
    List<StudyDeck> decks,
  ) async {
    final edited = await _showRevisionDialog(
      context,
      decks: decks,
      title: 'Edit revision',
      initial: revision,
    );
    if (edited == null || !context.mounted) return;
    final repository = ref.read(studyRepositoryProvider);
    await repository.updateRevision(
      revision.id,
      scheduledAt: edited.scheduledAt,
      note: edited.note,
      reminderEnabled: edited.reminderEnabled,
    );
    final updated = await repository.watchUpcomingRevisions().first.then(
      (revisions) => revisions.where((r) => r.id == revision.id).firstOrNull,
    );
    if (updated != null) {
      if (updated.reminderEnabled) {
        await scheduleRevisionNotification(ref, updated);
      } else {
        await cancelRevisionNotification(ref, updated.id);
      }
    }
  }

  Future<void> _deleteRevision(BuildContext context, WidgetRef ref, RevisionRecord revision) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete revision?'),
        content: const Text('This removes the scheduled revision. Your study set stays in your library.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(studyRepositoryProvider).deleteRevision(revision.id);
    await cancelRevisionNotification(ref, revision.id);
  }

  Future<void> _completeRevision(BuildContext context, WidgetRef ref, RevisionRecord revision) async {
    await ref.read(studyRepositoryProvider).completeRevision(revision.id);
    await cancelRevisionNotification(ref, revision.id);
  }

  Future<void> _openRevision(BuildContext context, WidgetRef ref, RevisionRecord revision) async {
    final loaded = await ref.read(generationJobProvider.notifier).loadDeck(revision.deckId);
    if (!context.mounted) return;
    if (!loaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('That study set is no longer available.')));
      return;
    }
    final deck = await ref.read(studyRepositoryProvider).getDeck(revision.deckId);
    if (!context.mounted) return;
    context.push(deck != null && deck.isQuiz ? AppRoutes.mcq : AppRoutes.deck);
  }
}

/// The upcoming revisions, streamed as they change.
final _upcomingRevisionsProvider = StreamProvider<List<RevisionRecord>>((ref) {
  return ref.watch(studyRepositoryProvider).watchUpcomingRevisions();
});

/// One daily-goal row: the study-time goal with its real progress.
class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.studiedMinutes,
    required this.goalMinutes,
    required this.fraction,
    required this.complete,
  });

  final int studiedMinutes;
  final int goalMinutes;
  final double fraction;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Daily goal', style: AppTextStyles.itemTitle(context))),
              Text(
                '$studiedMinutes / $goalMinutes min',
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: context.appPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(1.2)),
          StudyProgressTrack(fraction: fraction),
          SizedBox(height: context.h(1)),
          Row(
            children: [
              SvgPicture.asset(
                complete ? 'assets/icons/figma/circle_check.svg' : 'assets/icons/figma/circle.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  complete ? context.appPrimary : context.appNavInactive,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  complete
                      ? 'Goal reached for today.'
                      : 'Study time today, tracked from your sessions. Resets at midnight.',
                  style: AppTextStyles.caption(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One upcoming revision row: a day label, the deck title and time,
/// and a menu (open is the row tap; Edit / Complete / Delete are in
/// the menu).
class _RevisionRow extends StatelessWidget {
  const _RevisionRow({
    required this.revision,
    required this.deckTitle,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  final RevisionRecord revision;
  final String deckTitle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  String get _dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(revision.scheduledAt.year, revision.scheduledAt.month, revision.scheduledAt.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${revision.scheduledAt.day} ${months[revision.scheduledAt.month - 1]}';
  }

  String get _timeLabel {
    final time = revision.scheduledAt;
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final note = revision.note?.trim();
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Text(
                      _dayLabel,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.badge(context).copyWith(color: context.appPrimary),
                    ),
                    SizedBox(height: context.h(.25)),
                    Text(_timeLabel, style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deckTitle,
                      style: AppTextStyles.itemTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.h(.35)),
                    Text(
                      note == null || note.isEmpty
                          ? (revision.reminderEnabled ? 'Reminder on' : 'Reminder off')
                          : note,
                      style: AppTextStyles.badge(context).copyWith(color: context.appMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: context.appMuted),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'complete') {
                    onComplete();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'complete', child: Text('Mark complete')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The revision-reminder card: the persisted toggle, the preferred
/// time, and an honest note about what is scheduled.
class _ReminderCard extends ConsumerWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(revisionRemindersEnabledProvider).value ?? false;
    final timeMinutes = ref.watch(reminderTimeMinutesProvider).value ?? defaultReminderTimeMinutes;
    final timeLabel = _formatTime(timeMinutes);
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revision reminder', style: AppTextStyles.itemTitle(context)),
                    SizedBox(height: context.h(.25)),
                    Text(
                      enabled ? 'Optional · On' : 'Optional · Off',
                      style: AppTextStyles.badge(context).copyWith(color: context.appMuted),
                    ),
                  ],
                ),
              ),
              _ReminderToggle(
                value: enabled,
                onToggle: (value) async {
                  final ok = await setRevisionRemindersEnabled(ref, value);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notifications are off for SI Buddy. Turn them on in Android Settings > Apps > SI Buddy > Notifications to enable reminders.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SizedBox(height: context.h(1)),
          Row(
            children: [
              Expanded(child: Text('Preferred time', style: AppTextStyles.greeting(context))),
              InkWell(
                onTap: () => _pickTime(context, ref, timeMinutes),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: context.h(5.7),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timeLabel, style: AppTextStyles.greeting(context)),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/figma/clock.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(context.appNavInactive, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            enabled
                ? 'Revisions remind you at their scheduled time. The preferred time is for the daily study reminder.'
                : 'No reminder is scheduled. Enabling will ask for notification permission if needed.',
            style: AppTextStyles.badge(context).copyWith(color: context.appMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, int currentMinutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentMinutes ~/ 60, minute: currentMinutes % 60),
    );
    if (picked == null) return;
    await setReminderTimeMinutes(ref, picked.hour * 60 + picked.minute);
  }
}

/// The square SI Buddy toggle (40×24, radius 4): a border-colored
/// track with a white thumb when off, a primary track when on. The
/// visual stays 40×24, but the hit area is 48×48 and the control
/// announces its label and on/off state to screen readers.
class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({required this.value, required this.onToggle});

  final bool value;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Revision reminder',
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onToggle(!value),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: value ? context.appPrimary : context.appBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: context.appCard, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTime(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'AM' : 'PM';
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

/// The add/edit revision dialog's result.
class _RevisionDraft {
  _RevisionDraft({
    required this.deckId,
    required this.scheduledAt,
    required this.note,
    required this.reminderEnabled,
  });

  final int deckId;
  final DateTime scheduledAt;
  final String? note;
  final bool reminderEnabled;
}

/// A dialog to add a revision or edit one: pick the study set, the
/// date, the time, an optional note, and whether it reminds.
/// Returns null when cancelled.
Future<_RevisionDraft?> _showRevisionDialog(
  BuildContext context, {
  required List<StudyDeck> decks,
  required String title,
  RevisionRecord? initial,
}) async {
  if (decks.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Generate a study set first to schedule a revision.')));
    return null;
  }
  final initialDate = initial?.scheduledAt ?? DateTime.now();
  int deckId = initial?.deckId ?? decks.first.id;
  var date = DateTime(initialDate.year, initialDate.month, initialDate.day);
  var time = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
  final noteController = TextEditingController(text: initial?.note ?? '');
  var reminderEnabled = initial?.reminderEnabled ?? true;
  String? error;
  final draft = await showDialog<_RevisionDraft>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: deckId,
                decoration: const InputDecoration(labelText: 'Study set'),
                items: [
                  for (final deck in decks)
                    DropdownMenuItem(
                      value: deck.id,
                      child: Text(deck.title, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => deckId = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDate: date,
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      child: Text('${date.day}/${date.month}/${date.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: time);
                        if (picked != null) setState(() => time = picked);
                      },
                      child: Text(_formatTime(time.hour * 60 + time.minute)),
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: TextStyle(color: context.appDanger)),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. Review the hard cards',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Remind me'),
                value: reminderEnabled,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => reminderEnabled = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              if (scheduledAt.isBefore(DateTime.now())) {
                setState(() => error = 'Pick a time in the future.');
                return;
              }
              Navigator.of(dialogContext).pop(
                _RevisionDraft(
                  deckId: deckId,
                  scheduledAt: scheduledAt,
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                  reminderEnabled: reminderEnabled,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  noteController.dispose();
  return draft;
}

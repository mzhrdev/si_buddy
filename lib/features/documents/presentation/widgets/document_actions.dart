import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';

/// Shared document actions (Phase 4): the rename dialog, the delete
/// confirmation, the move-to-folder and change-subject pickers, the
/// generation opener, and the 3-dot overflow menu. The details screen
/// and the library cards use the same implementations, so a rename
/// behaves identically everywhere it is offered.

// ---------------------------------------------------------------------------
// Rename
// ---------------------------------------------------------------------------

/// Renames [document] via a dialog. The title must be non-empty,
/// different from the current title, and not a duplicate of another
/// document's title (case-insensitive). Returns the new title, or
/// null when the dialog was cancelled or nothing changed.
Future<String?> showRenameDocumentDialog(
  BuildContext context,
  WidgetRef ref,
  Document document,
) async {
  final allDocuments = ref.read(documentsStreamProvider).value ?? const [];
  final controller = TextEditingController(text: document.title);
  String? error;
  final newTitle = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Document title',
            errorText: error,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) {
                setState(() => error = 'Enter a title.');
                return;
              }
              if (value.toLowerCase() == document.title.trim().toLowerCase()) {
                Navigator.of(dialogContext).pop();
                return;
              }
              final duplicate = allDocuments.any(
                (other) =>
                    other.id != document.id &&
                    other.title.trim().toLowerCase() == value.toLowerCase(),
              );
              if (duplicate) {
                setState(
                  () => error = 'Another document already has this title.',
                );
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
  if (newTitle == null || newTitle.isEmpty) return null;
  await ref.read(documentRepositoryProvider).rename(document.id, newTitle);
  return newTitle;
}

// ---------------------------------------------------------------------------
// Delete
// ---------------------------------------------------------------------------

/// Asks whether to delete [document] — naming the document, its
/// extracted text and its study sets — and deletes it when confirmed.
/// The repository cascades the decks and removes the stored file.
/// Returns true when the document was deleted.
Future<bool> confirmDeleteDocument(
  BuildContext context,
  WidgetRef ref,
  Document document, {
  required int studySetCount,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete document?'),
      content: Text(
        'This deletes ${documentDisplayName(document)}, its extracted '
        'text${studySetCount == 0 ? '' : ' and $studySetCount study set${studySetCount == 1 ? '' : 's'}'}. '
        'This can\'t be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  await ref.read(documentRepositoryProvider).delete(document.id);
  return true;
}

// ---------------------------------------------------------------------------
// Move to folder / change subject
// ---------------------------------------------------------------------------

/// Picks the folder [document] lives in (or no folder), and moves
/// it. Returns true when a move happened.
Future<bool> showMoveToFolderDialog(
  BuildContext context,
  WidgetRef ref,
  Document document,
) async {
  final repository = ref.read(documentRepositoryProvider);
  final folders = await repository.listFolders();
  if (!context.mounted) return false;
  // -1 means "No folder": the dialog's result type is int, and null
  // means dismissed, so the no-folder choice needs its own value.
  final chosen = await showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Move to folder'),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<int>(
          groupValue: document.folderId ?? -1,
          onChanged: (value) => Navigator.of(dialogContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RadioListTile<int>(title: Text('No folder'), value: -1),
              for (final folder in folders)
                RadioListTile<int>(title: Text(folder.name), value: folder.id),
              if (folders.isEmpty)
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'No folders yet — create one from Organize documents.',
                    style: TextStyle(color: context.appMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
  if (chosen == null) return false;
  final folderId = chosen == -1 ? null : chosen;
  if (folderId == document.folderId) return false;
  await repository.moveToFolder(document.id, folderId);
  return true;
}

/// Picks the subject assigned to [document] (or Unassigned), and
/// assigns it. Returns true when a change happened.
Future<bool> showChangeSubjectDialog(
  BuildContext context,
  WidgetRef ref,
  Document document,
) async {
  final repository = ref.read(documentRepositoryProvider);
  final subjects = await repository.listSubjects();
  if (!context.mounted) return false;
  // -1 means "Unassigned": the dialog's result type is int, and
  // null means dismissed, so the unassigned choice needs its own
  // value.
  final chosen = await showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Change subject'),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<int>(
          groupValue: document.subjectId ?? -1,
          onChanged: (value) => Navigator.of(dialogContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RadioListTile<int>(title: Text('Unassigned'), value: -1),
              for (final subject in subjects)
                RadioListTile<int>(
                  title: Text(subject.name),
                  value: subject.id,
                ),
              if (subjects.isEmpty)
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'No subjects yet — create one from Organize documents.',
                    style: TextStyle(color: context.appMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
  if (chosen == null) return false;
  final subjectId = chosen == -1 ? null : chosen;
  if (subjectId == document.subjectId) return false;
  await repository.assignSubject(document.id, subjectId);
  return true;
}

// ---------------------------------------------------------------------------
// Generation entry point
// ---------------------------------------------------------------------------

/// Binds [document] as the generation source and opens the
/// generation setup (or the quiz setup when [quiz] is true).
/// Returns false when the document has no readable text to generate
/// from; the caller should show the reason.
Future<bool> openGenerationForDocument(
  BuildContext context,
  WidgetRef ref,
  Document document, {
  bool quiz = false,
}) async {
  final bound = await bindDocumentAsGenerationSource(ref, document.id);
  if (!context.mounted) return false;
  if (bound) {
    context.push(quiz ? AppRoutes.quizSetup : AppRoutes.generationSetup);
    return true;
  }
  return false;
}

// ---------------------------------------------------------------------------
// 3-dot overflow menu
// ---------------------------------------------------------------------------

/// The library card's overflow menu. Only actions that work for
/// [document] are offered; tapping the menu never navigates to the
/// document details on its own — Open does that explicitly.
Future<void> showDocumentMenu(
  BuildContext context,
  WidgetRef ref,
  Document document,
) async {
  final counts =
      ref.read(deckCountsByDocumentProvider).value ?? const <int, int>{};
  final studySets = counts[document.id] ?? 0;
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                documentDisplayName(document),
                style: AppTextStyles.itemTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.description_outlined,
            label: 'Open',
            value: 'open',
          ),
          _MenuItem(
            icon: Icons.style_outlined,
            label: 'Generate flashcards',
            value: 'flashcards',
          ),
          _MenuItem(
            icon: Icons.quiz_outlined,
            label: 'Create quiz',
            value: 'quiz',
          ),
          _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Rename',
            value: 'rename',
          ),
          _MenuItem(
            icon: Icons.folder_outlined,
            label: 'Move to folder',
            value: 'move',
          ),
          _MenuItem(
            icon: Icons.label_outlined,
            label: 'Change subject',
            value: 'subject',
          ),
          _MenuItem(
            icon: Icons.delete_outlined,
            label: 'Delete',
            value: 'delete',
            danger: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'open':
      ref.read(selectedDocumentIdProvider.notifier).select(document.id);
      context.push(AppRoutes.details);
    case 'flashcards':
    case 'quiz':
      final opened = await openGenerationForDocument(
        context,
        ref,
        document,
        quiz: action == 'quiz',
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This document has no readable text to generate from.',
            ),
          ),
        );
      }
    case 'rename':
      await showRenameDocumentDialog(context, ref, document);
    case 'move':
      await showMoveToFolderDialog(context, ref, document);
    case 'subject':
      await showChangeSubjectDialog(context, ref, document);
    case 'delete':
      final deleted = await confirmDeleteDocument(
        context,
        ref,
        document,
        studySetCount: studySets,
      );
      if (deleted) {
        ref.read(selectedDocumentIdProvider.notifier).clear();
      }
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.value,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: danger ? context.appDanger : context.appText),
      title: Text(
        label,
        style: AppTextStyles.body(context).copyWith(
          color: danger ? context.appDanger : null,
        ),
      ),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

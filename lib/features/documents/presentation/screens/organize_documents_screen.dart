import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../providers/library_providers.dart';

/// Organize documents, implemented from the Figma frame
/// "SI Buddy · Organize Documents" (4:12019).
///
/// Folders are user-created containers a document lives in
/// (deleting one never deletes its documents — they become
/// unfiled); subjects are categories assigned to documents
/// (deleting one leaves its documents Unassigned). Both lists are
/// the real persisted folders and subjects, with their document
/// counts; expanding a row shows its documents. Creation, rename
/// and deletion all work here.
class OrganizeDocumentsScreen extends ConsumerWidget {
  const OrganizeDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(libraryFoldersProvider).value ?? const [];
    final subjects = ref.watch(librarySubjectsProvider).value ?? const [];
    final documents = ref.watch(documentsStreamProvider).value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Organize documents', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [
                  _SectionHeader(
                    title: 'Folders',
                    actionLabel: 'Create folder',
                    onAction: () => _createFolder(context, ref, folders),
                  ),
                  const SizedBox(height: 8),
                  if (folders.isEmpty)
                    const Text(
                      'No folders yet. Create one to group documents together.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  for (final folder in folders)
                    _FolderTile(
                      folder: folder,
                      documents: documents
                          .where((d) => d.folderId == folder.id)
                          .toList(),
                      onRename: () =>
                          _renameFolder(context, ref, folder, folders),
                      onDelete: () => _deleteFolder(context, ref, folder),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Subjects',
                    actionLabel: 'Create subject',
                    onAction: () => _createSubject(context, ref, subjects),
                  ),
                  const SizedBox(height: 8),
                  if (subjects.isEmpty && documents.isEmpty)
                    const Text(
                      'No subjects yet. Create one to categorize documents.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  for (final subject in subjects)
                    _SubjectTile(
                      subject: subject,
                      documents: documents
                          .where((d) => d.subjectId == subject.id)
                          .toList(),
                      onRename: () =>
                          _renameSubject(context, ref, subject, subjects),
                      onDelete: () => _deleteSubject(context, ref, subject),
                    ),
                  _SubjectTile(
                    subject: null,
                    documents: documents
                        .where((d) => d.subjectId == null)
                        .toList(),
                    onRename: null,
                    onDelete: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFolder(
    BuildContext context,
    WidgetRef ref,
    List<DocumentFolder> folders,
  ) async {
    final name = await _showNameDialog(
      context,
      title: 'Create folder',
      hintText: 'Folder name',
      existingNames: folders.map((f) => f.name).toList(),
    );
    if (name == null) return;
    await ref.read(documentRepositoryProvider).createFolder(name);
  }

  Future<void> _createSubject(
    BuildContext context,
    WidgetRef ref,
    List<DocumentSubject> subjects,
  ) async {
    final name = await _showNameDialog(
      context,
      title: 'Create subject',
      hintText: 'Subject name',
      existingNames: subjects.map((s) => s.name).toList(),
    );
    if (name == null) return;
    await ref.read(documentRepositoryProvider).createSubject(name);
  }

  Future<void> _renameFolder(
    BuildContext context,
    WidgetRef ref,
    DocumentFolder folder,
    List<DocumentFolder> folders,
  ) async {
    final name = await _showNameDialog(
      context,
      title: 'Rename folder',
      hintText: 'Folder name',
      initialValue: folder.name,
      existingNames: folders
          .where((f) => f.id != folder.id)
          .map((f) => f.name)
          .toList(),
    );
    if (name == null || name == folder.name) return;
    await ref.read(documentRepositoryProvider).renameFolder(folder.id, name);
  }

  Future<void> _renameSubject(
    BuildContext context,
    WidgetRef ref,
    DocumentSubject subject,
    List<DocumentSubject> subjects,
  ) async {
    final name = await _showNameDialog(
      context,
      title: 'Rename subject',
      hintText: 'Subject name',
      initialValue: subject.name,
      existingNames: subjects
          .where((s) => s.id != subject.id)
          .map((s) => s.name)
          .toList(),
    );
    if (name == null || name == subject.name) return;
    await ref.read(documentRepositoryProvider).renameSubject(subject.id, name);
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    DocumentFolder folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'This deletes the folder "${folder.name}". Its documents stay in your library — they just won\'t be in a folder any more.',
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
    if (confirmed == true) {
      await ref.read(documentRepositoryProvider).deleteFolder(folder.id);
    }
  }

  Future<void> _deleteSubject(
    BuildContext context,
    WidgetRef ref,
    DocumentSubject subject,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete subject?'),
        content: Text(
          'This deletes the subject "${subject.name}". Its documents stay in your library and become Unassigned.',
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
    if (confirmed == true) {
      await ref.read(documentRepositoryProvider).deleteSubject(subject.id);
    }
  }

  /// A name-entry dialog with empty and duplicate validation.
  /// Returns the entered name, or null when cancelled or unchanged.
  Future<String?> _showNameDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    required List<String> existingNames,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    String? error;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hintText, errorText: error),
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
                  setState(() => error = 'Enter a name.');
                  return;
                }
                if (value.toLowerCase() ==
                    (initialValue ?? '').trim().toLowerCase()) {
                  Navigator.of(dialogContext).pop();
                  return;
                }
                if (existingNames.any(
                  (n) => n.trim().toLowerCase() == value.toLowerCase(),
                )) {
                  setState(() => error = 'That name is already used.');
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
    return name;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        GestureDetector(
          onTap: onAction,
          child: Text(actionLabel, style: AppTextStyles.link),
        ),
      ],
    );
  }
}

/// One folder row: expandable to its documents, with a rename/delete
/// menu.
class _FolderTile extends ConsumerWidget {
  const _FolderTile({
    required this.folder,
    required this.documents,
    required this.onRename,
    required this.onDelete,
  });

  final DocumentFolder folder;
  final List<Document> documents;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OrganizeTile(
      icon: Icons.folder_outlined,
      title: folder.name,
      countLabel:
          '${documents.length} document${documents.length == 1 ? '' : 's'}',
      documents: documents,
      onRename: onRename,
      onDelete: onDelete,
    );
  }
}

/// One subject row: expandable to its documents, with a rename/delete
/// menu. A null subject is the Unassigned row (no menu).
class _SubjectTile extends ConsumerWidget {
  const _SubjectTile({
    required this.subject,
    required this.documents,
    required this.onRename,
    required this.onDelete,
  });

  final DocumentSubject? subject;
  final List<Document> documents;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OrganizeTile(
      icon: Icons.label_outlined,
      title: subject?.name ?? 'Unassigned',
      countLabel:
          '${documents.length} document${documents.length == 1 ? '' : 's'}',
      documents: documents,
      onRename: onRename,
      onDelete: onDelete,
    );
  }
}

class _OrganizeTile extends ConsumerWidget {
  const _OrganizeTile({
    required this.icon,
    required this.title,
    required this.countLabel,
    required this.documents,
    required this.onRename,
    required this.onDelete,
  });

  final IconData icon;
  final String title;
  final String countLabel;
  final List<Document> documents;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.itemTitle),
        subtitle: Text(countLabel, style: AppTextStyles.caption),
        trailing: onRename == null
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.muted),
                onSelected: (value) {
                  if (value == 'rename') {
                    onRename!();
                  } else if (value == 'delete') {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
        children: [
          if (documents.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No documents here yet.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          for (final document in documents)
            ListTile(
              title: Text(
                documentDisplayName(document),
                style: AppTextStyles.itemTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${document.format.label} · ${formatLibraryDate(document.createdAt)}',
                style: AppTextStyles.caption,
              ),
              onTap: () {
                ref
                    .read(selectedDocumentIdProvider.notifier)
                    .select(document.id);
                context.push(AppRoutes.details);
              },
            ),
        ],
      ),
    );
  }
}

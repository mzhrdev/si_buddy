import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class DesignScreen extends StatelessWidget {
  const DesignScreen({required this.title, required this.feature, super.key});

  final String title;
  final String feature;

  @override
  Widget build(BuildContext context) {
    final isError = title.contains('Failure') ||
        title.contains('Failed') ||
        title.contains('Unreadable') ||
        title.contains('Corrupted') ||
        title.contains('Unsupported') ||
        title.contains('Low Memory') ||
        title.contains('Insufficient');
    final isSuccess = title.contains('Success') || title.contains('Ready');
    final isConfirmation = title.contains('Confirmation') || title.contains('Delete');
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title),
        actions: const [Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.menu_book))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text(feature, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Text(_heading, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(_description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          if (isError)
            const _StateCard(icon: Icons.error_outline, color: Colors.red, label: 'Something needs attention')
          else if (isSuccess)
            const _StateCard(icon: Icons.check_circle_outline, color: Colors.green, label: 'Ready to continue')
          else if (isConfirmation)
            const _StateCard(icon: Icons.help_outline, color: AppTheme.primary, label: 'Please confirm this action')
          else
            _ContentPreview(title: title),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo interaction. Persistence and backend services are not connected.')),
            ),
            child: Text(isConfirmation ? 'Confirm' : isError ? 'Try again' : 'Continue'),
          ),
          if (isConfirmation || isError)
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  String get _heading {
    if (title.contains('Home')) return 'Your study space';
    if (title.contains('Library') || title.contains('Documents')) return 'Your notes, organized.';
    if (title.contains('Quiz')) return 'Practice with purpose.';
    if (title.contains('Card') || title.contains('Deck')) return 'Build lasting recall.';
    if (title.contains('Premium') || title.contains('Payment')) return 'More room for your routine.';
    return title;
  }

  String get _description => 'A focused, private workflow for $feature. This screen follows the Swiss Blue design system and uses local mock data until the related service is connected.';
}

class _ContentPreview extends StatelessWidget {
  const _ContentPreview({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final item in _items(title))
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.surface, child: Icon(Icons.auto_awesome, color: AppTheme.primary)),
                title: Text(item),
                subtitle: const Text('Mock data · Available offline'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
        ],
      );
}

List<String> _items(String title) {
  if (title.contains('Quiz')) return ['Cell Biology quiz', 'Organic Chemistry quiz', 'Practice questions'];
  if (title.contains('Model')) return ['Phi-3 Mini · 2.4 GB', 'TinyLlama · 1.1 GB'];
  if (title.contains('Settings') || title.contains('Preferences')) return ['Appearance', 'Language', 'Reminders'];
  if (title.contains('Study')) return ['Cell structures', 'Chemical bonds', 'Revision plan'];
  return ['Cell Biology · Chapter 4', 'Organic Chemistry', 'Research Methods'];
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
        color: color.withValues(alpha: .08),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [Icon(icon, color: color, size: 32), const SizedBox(width: 16), Expanded(child: Text(label, style: Theme.of(context).textTheme.titleLarge))]),
        ),
      );
}

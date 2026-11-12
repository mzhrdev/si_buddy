import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/model_management/presentation/providers/model_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// The app root. Observes the app lifecycle so returning from the
/// background re-probes the model state instead of trusting the
/// last-known value — the model can change while the app is away,
/// and Home must show its real state on a cold start too.
///
/// [restorationScopeId] lets the framework restore the navigation
/// stack after a genuine process death, so a cold start returns the
/// user to where they were instead of always replaying splash →
/// onboarding (the reported "app restarts on background" symptom).
/// Together with persisted onboarding state, a cold start now lands
/// on Home with the library intact.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Probe once after the first frame: Home reads the real model
    // state on a cold start instead of "not installed" until a model
    // screen is visited.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(modelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Light Mode only (the 2026-11-12 restyle removed Dark/System):
    // a single light theme, no appearance setting.
    return MaterialApp.router(
      title: 'SI Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      restorationScopeId: 'si-buddy',
    );
  }
}

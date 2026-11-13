import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';

/// Root scaffold for the tabbed area (Home, Library, Study, Settings).
/// Hosts the [StatefulNavigationShell] from GoRouter and the shared
/// [AppBottomNav]; each tab keeps its own navigation stack.
///
/// Back-button contract (2026-11-13): the system back button never
/// just pops one screen off a long stack and leaves the user
/// nowhere. When a pushed page or a nested branch page is showing,
/// back pops it normally. At a tab root, back first returns to the
/// Home tab; on the Home tab it exits the app. The [PopScope] only
/// intercepts presses that reach the shell itself — a pushed route
/// above the shell pops through the root navigator untouched.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        // A pushed page or a nested page inside a tab: pop it.
        if (router.canPop()) {
          router.pop();
          return;
        }
        // At a tab root: any tab but Home goes home first.
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
          return;
        }
        // Already on Home: exit the app.
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

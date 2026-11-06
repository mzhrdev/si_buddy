import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/empty_state.dart';
import 'router.dart';

/// Shown for unknown routes. The previous behaviour silently fell
/// back to the home dashboard, which masked broken links and left
/// the user somewhere unexpected with no explanation. A dead link
/// now says so and offers the way home.
class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'Page not found',
          message:
              'This screen doesn\'t exist. You may have followed an old link.',
          actionLabel: 'Go to Home',
          onAction: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}

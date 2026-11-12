import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Segmented "Study destinations" bar shown at the top of the Study
/// screens (Statistics, Planner). The active destination is
/// highlighted with the selected surface color; tapping another
/// destination replaces the current study screen.
///
/// The Library and Revision sub-tabs were removed in Phase 5: the
/// library already lives in the bottom navigation, and revision
/// scheduling lives in the Planner.
class StudyDestinationsBar extends StatelessWidget {
  const StudyDestinationsBar({required this.currentIndex, super.key});

  /// Index of the active destination: 0 Statistics, 1 Planner.
  final int currentIndex;

  static const _labels = ['Statistics', 'Planner'];
  static const _routes = [AppRoutes.statistics, AppRoutes.planner];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == currentIndex,
                button: true,
                child: GestureDetector(
                  onTap: i == currentIndex
                      ? null
                      : () => context.go(_routes[i]),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? context.appSurface
                          : context.appCard,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _labels[i],
                      style: AppTextStyles.navLabel(context).copyWith(
                        color: i == currentIndex
                            ? context.appPrimary
                            : context.appMuted,
                        fontWeight: i == currentIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

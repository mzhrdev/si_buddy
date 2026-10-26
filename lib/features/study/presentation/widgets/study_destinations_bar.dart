import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Segmented "Study destinations" bar shown at the top of the Study
/// screens (Library, Revision, Statistics, Planner). The active
/// destination is highlighted with the selected surface color; tapping
/// another destination replaces the current study screen.
class StudyDestinationsBar extends StatelessWidget {
  const StudyDestinationsBar({required this.currentIndex, super.key});

  /// Index of the active destination: 0 Library, 1 Revision,
  /// 2 Statistics, 3 Planner.
  final int currentIndex;

  static const _labels = ['Library', 'Revision', 'Statistics', 'Planner'];
  static const _routes = [
    AppRoutes.studyLibrary,
    AppRoutes.revision,
    AppRoutes.statistics,
    AppRoutes.planner,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: i == currentIndex ? null : () => context.go(_routes[i]),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? AppColors.surface
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _labels[i],
                    style: AppTextStyles.navLabel.copyWith(
                      color: i == currentIndex
                          ? AppColors.primary
                          : AppColors.muted,
                      fontWeight: i == currentIndex
                          ? FontWeight.w600
                          : FontWeight.w400,
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

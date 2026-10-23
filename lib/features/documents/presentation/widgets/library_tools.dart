import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'global_search_field.dart';

/// The "Library tools" block shared by the list and grid library screens:
/// the global search field, the "Folders & subjects" organization entry,
/// and the sort / filters / view-toggle controls row.
class LibraryTools extends StatelessWidget {
  const LibraryTools({
    required this.gridView,
    required this.onSearchTap,
    required this.onOrganizeTap,
    required this.onSortTap,
    required this.onFiltersTap,
    required this.onShowList,
    required this.onShowGrid,
    super.key,
  });

  /// Which view option is highlighted in the toggle.
  final bool gridView;
  final VoidCallback onSearchTap;
  final VoidCallback onOrganizeTap;
  final VoidCallback onSortTap;
  final VoidCallback onFiltersTap;
  final VoidCallback onShowList;
  final VoidCallback onShowGrid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlobalSearchField(
          hintText: 'Search all your study material',
          onTap: onSearchTap,
        ),
        const SizedBox(height: 12),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onOrganizeTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/folders.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Folders & subjects',
                          style: AppTextStyles.itemTitle,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '2 folders · 3 subjects',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text('Organize', style: AppTextStyles.link),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/icons/figma/chevron_right.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.muted,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onSortTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/arrow_down_wide_narrow.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Newest first',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    SvgPicture.asset(
                      'assets/icons/figma/chevron_down.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onFiltersTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/sliders_horizontal.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Filters',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 34,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewOption(
                      iconAsset: 'assets/icons/figma/list.svg',
                      selected: !gridView,
                      onTap: onShowList,
                    ),
                    const SizedBox(width: 2),
                    _ViewOption(
                      iconAsset: 'assets/icons/figma/layout_grid.svg',
                      selected: gridView,
                      onTap: onShowGrid,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One 30×28 option of the list/grid view toggle.
class _ViewOption extends StatelessWidget {
  const _ViewOption({
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : AppColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 30,
          height: 28,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: 17,
              height: 17,
              colorFilter: ColorFilter.mode(
                selected ? AppColors.primary : AppColors.navInactive,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

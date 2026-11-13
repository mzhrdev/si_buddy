import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/library_providers.dart';

/// The "Library tools" block shared by the list and grid library screens:
/// the "Folders & subjects" organization entry (with real counts) and
/// the sort / filters / view-toggle controls row. The sort label shows
/// the active sort, and the Filters button carries a badge with the
/// number of active filter groups. The search field lives above this
/// block, in the screens themselves (inline search with a results
/// panel — see [LibrarySearchPanel]).
class LibraryTools extends ConsumerWidget {
  const LibraryTools({
    required this.gridView,
    required this.onOrganizeTap,
    required this.onSortTap,
    required this.onFiltersTap,
    required this.onShowList,
    required this.onShowGrid,
    super.key,
  });

  /// Which view option is highlighted in the toggle.
  final bool gridView;
  final VoidCallback onOrganizeTap;
  final VoidCallback onSortTap;
  final VoidCallback onFiltersTap;
  final VoidCallback onShowList;
  final VoidCallback onShowGrid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    final folders = ref.watch(libraryFoldersProvider).value ?? const [];
    final subjects = ref.watch(librarySubjectsProvider).value ?? const [];
    final activeFilters = filter.activeFilterCount;

    return Column(
      children: [
        Material(
          color: context.appCard,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onOrganizeTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/figma/folders.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      context.appPrimary,
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
                          style: AppTextStyles.itemTitle(context),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${folders.length} folder${folders.length == 1 ? '' : 's'} · ${subjects.length} subject${subjects.length == 1 ? '' : 's'}',
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),
                  Text('Organize', style: AppTextStyles.link(context)),
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/svgs/figma/chevron_right.svg',
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      context.appMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onSortTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/figma/arrow_down_wide_narrow.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          context.appNavInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        filter.sort.label,
                        style: AppTextStyles.body(
                          context,
                        ).copyWith(fontSize: 12, height: 18 / 12),
                      ),
                      const SizedBox(width: 5),
                      SvgPicture.asset(
                        'assets/svgs/figma/chevron_down.svg',
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          context.appNavInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onFiltersTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/figma/sliders_horizontal.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          context.appNavInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Filters',
                        style: AppTextStyles.body(
                          context,
                        ).copyWith(fontSize: 12, height: 18 / 12),
                      ),
                      if (activeFilters > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.appChip,
                            border: Border.all(color: context.appBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$activeFilters',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.appTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: context.appCard,
                  border: Border.all(color: context.appBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewOption(
                      iconAsset: 'assets/svgs/figma/list.svg',
                      selected: !gridView,
                      onTap: onShowList,
                    ),
                    const SizedBox(width: 2),
                    _ViewOption(
                      iconAsset: 'assets/svgs/figma/layout_grid.svg',
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
      color: selected ? context.appSurface : context.appCard,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: 17,
              height: 17,
              colorFilter: ColorFilter.mode(
                selected ? context.appPrimary : context.appNavInactive,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

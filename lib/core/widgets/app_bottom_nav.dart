import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Destination in the app's bottom navigation bar.
class AppNavDestination {
  const AppNavDestination({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

/// Bottom navigation matching the Figma design: four destinations
/// (Home, Library, Study, Settings), a 56×30 pill behind the active
/// icon, and an 11px label under each icon.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const destinations = <AppNavDestination>[
    AppNavDestination(label: 'Home', iconAsset: 'assets/icons/figma/house.svg'),
    AppNavDestination(
      label: 'Library',
      iconAsset: 'assets/icons/figma/folder_open.svg',
    ),
    AppNavDestination(
      label: 'Study',
      iconAsset: 'assets/icons/figma/layers_nav.svg',
    ),
    AppNavDestination(
      label: 'Settings',
      iconAsset: 'assets/icons/figma/settings.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.navInactive;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SizedBox(
              width: 56,
              height: 30,
              child: Center(
                child: SvgPicture.asset(
                  destination.iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: AppTextStyles.navLabel.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

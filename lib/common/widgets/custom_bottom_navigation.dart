// lib/common/widgets/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget? badge;

  NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badge,
  });
}

class CustomBottomNavigation extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;
  final double iconSize;
  final double elevation;
  final Color? backgroundColor;

  const CustomBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
    this.iconSize = 24,
    this.elevation = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: elevation,
            spreadRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = index == currentIndex;
    final navItem = items[index];

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration:
            isActive
                ? BoxDecoration(
                  color: ColorTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? navItem.activeIcon : navItem.icon,
                  size: iconSize,
                  color:
                      isActive ? ColorTheme.primary : ColorTheme.textSecondary,
                ),
                if (navItem.badge != null)
                  Positioned(top: -4, right: -6, child: navItem.badge!),
              ],
            ),
            if (showLabels) ...[
              const SizedBox(height: 4),
              Text(
                navItem.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive ? ColorTheme.primary : ColorTheme.textSecondary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

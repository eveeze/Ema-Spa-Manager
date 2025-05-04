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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: 8),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
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
              SizedBox(height: 4),
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

// lib/common/widgets/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:flutter/services.dart';

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

class CustomBottomNavigation extends StatefulWidget {
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
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: widget.elevation,
            spreadRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(widget.items.length, (index) {
              return Expanded(child: _buildNavItem(index));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = index == widget.currentIndex;
    final navItem = widget.items[index];

    // Scale animation for the active item
    final Animation<double> scaleAnimation = Tween<double>(
      begin: 1.0,
      end: isActive ? 1.0 : 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Play haptic feedback for better tactile response
          HapticFeedback.lightImpact();
          widget.onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration:
              isActive
                  ? BoxDecoration(
                    color: ColorTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ColorTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  )
                  : null,
          child: ScaleTransition(
            scale: isActive ? _animationController : scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(2),
                      decoration:
                          isActive
                              ? BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorTheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                              )
                              : null,
                      child: Icon(
                        isActive ? navItem.activeIcon : navItem.icon,
                        size: isActive ? widget.iconSize + 2 : widget.iconSize,
                        color:
                            isActive
                                ? ColorTheme.primary
                                : ColorTheme.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                      ),
                    ),
                    if (navItem.badge != null)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.5, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: navItem.badge!,
                        ),
                      ),
                  ],
                ),
                if (widget.showLabels) ...[
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isActive
                                ? ColorTheme.primary
                                : ColorTheme.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                        fontFamily: 'JosefinSans',
                        letterSpacing: isActive ? 0.2 : 0,
                      ),
                      child: Text(
                        navItem.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

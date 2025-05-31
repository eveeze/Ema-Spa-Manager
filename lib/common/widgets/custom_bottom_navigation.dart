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
  final Color? activeColor;
  final Color? inactiveColor;
  final bool isNavigating; // Add navigation state awareness

  const CustomBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
    this.iconSize = 26,
    this.elevation = 12,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.isNavigating = false,
  });

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  // Animation controllers - optimized for performance
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rippleController;

  // Animation objects
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Performance optimizations
  DateTime _lastTapTime = DateTime.now();
  static const Duration _tapDebounceTime = Duration(
    milliseconds: 200,
  ); // Reduced for responsiveness

  // State management
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Defer initial animation to next frame for better performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized = true;
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  void _initializeAnimations() {
    // Slide indicator - optimized timing
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300), // Faster for responsiveness
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic, // Smoother curve
    );

    // Scale animation - subtle and fast
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Ripple effect for immediate feedback
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex && _isInitialized) {
      _handleIndexChange();
    }
  }

  void _handleIndexChange() {
    if (!mounted) return;

    // Quick animation for immediate feedback
    _slideController.reset();
    _slideController.forward();

    // Scale animation for active item
    _scaleController.forward().then((_) {
      if (mounted) {
        _scaleController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildNavContainer(context);
  }

  Widget _buildNavContainer(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: _buildShadowDecoration(),
      child: ClipPath(
        clipper: BottomNavClipper(),
        child: Container(
          decoration: _buildBackgroundDecoration(),
          child: Container(
            padding: EdgeInsets.only(
              top: 12, // Reduced padding for better proportions
              bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
              left: 8,
              right: 8,
            ),
            child: Stack(
              children: [_buildSlideIndicator(screenWidth), _buildNavItems()],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildShadowDecoration() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: widget.elevation,
          spreadRadius: 0,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: widget.elevation / 2,
          spreadRadius: 0,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    final bgColor = widget.backgroundColor ?? Colors.white;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgColor.withValues(alpha: 0.98), bgColor],
      ),
    );
  }

  Widget _buildSlideIndicator(double screenWidth) {
    final itemWidth = (screenWidth - 16) / widget.items.length;
    final activeColor = widget.activeColor ?? ColorTheme.primary;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: widget.currentIndex * itemWidth + (itemWidth * 0.3),
          child: Container(
            width: itemWidth * 0.4,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [activeColor, activeColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => Expanded(child: _buildNavItem(index)),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = index == widget.currentIndex;
    final navItem = widget.items[index];
    final activeColor = widget.activeColor ?? ColorTheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? ColorTheme.textSecondary.withValues(alpha: 0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(24),
        splashColor: activeColor.withValues(alpha: 0.15),
        highlightColor: activeColor.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: _buildItemDecoration(isActive, activeColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(navItem, isActive, activeColor, inactiveColor, index),
              if (widget.showLabels) ...[
                const SizedBox(height: 6),
                _buildLabel(navItem, isActive, activeColor, inactiveColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration? _buildItemDecoration(bool isActive, Color activeColor) {
    if (!isActive) return null;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          activeColor.withValues(alpha: 0.08),
          activeColor.withValues(alpha: 0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: activeColor.withValues(alpha: 0.15),
        width: 1.0,
      ),
    );
  }

  Widget _buildIcon(
    NavItem navItem,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
    int index,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = isActive ? _scaleAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration:
                    isActive
                        ? BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              activeColor.withValues(alpha: 0.12),
                              activeColor.withValues(alpha: 0.03),
                            ],
                          ),
                          shape: BoxShape.circle,
                        )
                        : null,
                child: _buildAnimatedIcon(
                  navItem,
                  isActive,
                  activeColor,
                  inactiveColor,
                ),
              ),
            );
          },
        ),
        if (navItem.badge != null)
          Positioned(
            top: -6,
            right: -8,
            child: Transform.scale(
              scale: isActive ? 1.05 : 1.0,
              child: navItem.badge!,
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedIcon(
    NavItem navItem,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0, end: isActive ? 1 : 0),
      builder: (context, value, child) {
        return Icon(
          isActive ? navItem.activeIcon : navItem.icon,
          size: widget.iconSize + (value * 1.5),
          color: Color.lerp(inactiveColor, activeColor, value),
        );
      },
    );
  }

  Widget _buildLabel(
    NavItem navItem,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0, end: isActive ? 1 : 0),
      builder: (context, value, child) {
        return Text(
          navItem.label,
          style: TextStyle(
            fontSize: 10 + (value * 1.0),
            fontWeight: FontWeight.lerp(
              FontWeight.w500,
              FontWeight.w600,
              value,
            ),
            color: Color.lerp(inactiveColor, activeColor, value),
            fontFamily: 'JosefinSans',
            letterSpacing: value * 0.2,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  void _handleTap(int index) {
    // Enhanced debounce logic
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < _tapDebounceTime) {
      return;
    }
    _lastTapTime = now;

    // Validation
    if (index < 0 ||
        index >= widget.items.length ||
        index == widget.currentIndex ||
        widget.isNavigating) {
      return;
    }

    // Immediate haptic feedback
    HapticFeedback.lightImpact();

    // Immediate visual feedback
    _rippleController.forward().then((_) {
      if (mounted) {
        _rippleController.reverse();
      }
    });

    // Execute callback immediately for responsiveness
    widget.onTap(index);
  }
}

// Optimized clipper with caching
class BottomNavClipper extends CustomClipper<Path> {
  static Path? _cachedPath;
  static Size? _cachedSize;

  @override
  Path getClip(Size size) {
    // Cache path for performance
    if (_cachedPath != null && _cachedSize == size) {
      return _cachedPath!;
    }

    final path = Path();
    const double radius = 28.0;
    const double centerCurveHeight = 6.0;

    // Start from top-left
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge with subtle center curve
    final centerX = size.width / 2;
    path.lineTo(centerX - 50, 0);
    path.quadraticBezierTo(centerX, centerCurveHeight, centerX + 50, 0);

    // Continue to top-right
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Complete the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.close();

    // Cache for reuse
    _cachedPath = path;
    _cachedSize = size;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

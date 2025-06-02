// lib/common/widgets/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
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
  final bool isNavigating;

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
  static const Duration _tapDebounceTime = Duration(milliseconds: 200);

  // State management
  bool _isInitialized = false;

  // Theme controller
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
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

  // Enhanced theme-aware color getters using ThemeController
  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    // PERBAIKAN: Gunakan warna yang sama dengan scaffold background
    return _themeController.isDarkMode
        ? ColorTheme
            .backgroundDark // Gunakan background yang sama dengan halaman
        : ColorTheme.background; // Gunakan background yang sama dengan halaman
  }

  Color _getActiveColor() {
    if (widget.activeColor != null) return widget.activeColor!;

    return _themeController.isDarkMode
        ? ColorTheme.primaryLightDark
        : ColorTheme.bottomNavActive;
  }

  Color _getInactiveColor() {
    if (widget.inactiveColor != null) return widget.inactiveColor!;

    return _themeController.isDarkMode
        ? ColorTheme.textTertiaryDark
        : ColorTheme.bottomNavInactive;
  }

  Color _getShadowColor() {
    return _themeController.isDarkMode
        ? Colors.black.withValues(
          alpha: 0.2,
        ) // Kurangi opacity shadow di dark mode
        : Colors.black.withValues(
          alpha: 0.08,
        ); // Kurangi opacity di light mode juga
  }

  Color _getBorderColor() {
    return _themeController.isDarkMode
        ? Colors
            .transparent // Hilangkan border di dark mode untuk seamless look
        : ColorTheme.border.withValues(
          alpha: 0.3,
        ); // Kurangi opacity border di light mode
  }

  Color _getGradientStartColor() {
    final bgColor = _getBackgroundColor();
    return _themeController.isDarkMode
        ? bgColor // Gunakan warna solid yang sama untuk seamless
        : bgColor.withValues(alpha: 0.98);
  }

  Color _getIndicatorShadowColor() {
    final activeColor = _getActiveColor();
    return _themeController.isDarkMode
        ? activeColor.withValues(alpha: 0.3) // Kurangi opacity
        : activeColor.withValues(alpha: 0.4);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Listen to theme changes
      _themeController.isDarkMode; // This ensures rebuild on theme change

      return _buildNavContainer(context);
    });
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
              top: 12,
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
    final shadowColor = _getShadowColor();

    return BoxDecoration(
      boxShadow:
          _themeController.isDarkMode
              ? [
                // Shadow yang lebih subtle untuk dark mode
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation * 0.6, // Kurangi blur radius
                  spreadRadius: 0,
                  offset: const Offset(0, -2), // Kurangi offset
                ),
              ]
              : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation,
                  spreadRadius: 0,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.06),
                  blurRadius: widget.elevation / 2,
                  spreadRadius: 0,
                  offset: const Offset(0, -2),
                ),
              ],
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    final bgColor = _getBackgroundColor();
    final gradientStart = _getGradientStartColor();

    return BoxDecoration(
      // PERBAIKAN: Gunakan solid color untuk dark mode, gradient untuk light mode
      color: _themeController.isDarkMode ? bgColor : null,
      gradient:
          _themeController.isDarkMode
              ? null // Tidak ada gradient di dark mode untuk seamless
              : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradientStart, bgColor],
              ),
      // Enhanced border for better definition
      border: Border(
        top: BorderSide(
          color: _getBorderColor(),
          width:
              _themeController.isDarkMode
                  ? 0.0
                  : 0.5, // Hilangkan border di dark mode
        ),
      ),
    );
  }

  Widget _buildSlideIndicator(double screenWidth) {
    final itemWidth = (screenWidth - 16) / widget.items.length;
    final activeColor = _getActiveColor();
    final shadowColor = _getIndicatorShadowColor();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: widget.currentIndex * itemWidth + (itemWidth * 0.3),
          child: Container(
            width: itemWidth * 0.4,
            height:
                _themeController.isDarkMode
                    ? 3
                    : 3, // Sama tinggi untuk konsistensi
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _themeController.isDarkMode
                        ? [activeColor, activeColor.withValues(alpha: 0.7)]
                        : [activeColor, activeColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _themeController.isDarkMode ? 6 : 6, // Konsisten
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
    final activeColor = _getActiveColor();
    final inactiveColor = _getInactiveColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(24),
        splashColor: activeColor.withValues(
          alpha: _themeController.isDarkMode ? 0.15 : 0.15, // Konsisten
        ),
        highlightColor: activeColor.withValues(
          alpha: _themeController.isDarkMode ? 0.08 : 0.08, // Konsisten
        ),
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
        colors:
            _themeController.isDarkMode
                ? [
                  activeColor.withValues(alpha: 0.15), // Kurangi opacity
                  activeColor.withValues(alpha: 0.08),
                ]
                : [
                  activeColor.withValues(alpha: 0.08),
                  activeColor.withValues(alpha: 0.04),
                ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: activeColor.withValues(
          alpha: _themeController.isDarkMode ? 0.25 : 0.15, // Kurangi opacity
        ),
        width: 1.0, // Konsisten
      ),
      // Add subtle shadow for active item in dark mode
      boxShadow:
          _themeController.isDarkMode
              ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.08), // Kurangi opacity
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
              : null,
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
                            colors:
                                _themeController.isDarkMode
                                    ? [
                                      activeColor.withValues(
                                        alpha: 0.18,
                                      ), // Kurangi opacity
                                      activeColor.withValues(alpha: 0.06),
                                    ]
                                    : [
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
          size: widget.iconSize + (value * 1.5), // Konsisten untuk semua theme
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
            fontSize: 10 + (value * 1.0), // Konsisten untuk semua theme
            fontWeight: FontWeight.lerp(
              FontWeight.w500,
              FontWeight.w600, // Konsisten untuk semua theme
              value,
            ),
            color: Color.lerp(inactiveColor, activeColor, value),
            fontFamily: 'JosefinSans',
            letterSpacing: value * 0.2, // Konsisten
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

    // Enhanced haptic feedback based on theme
    HapticFeedback.lightImpact(); // Konsisten untuk semua theme

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

// Enhanced clipper with theme-aware styling
class BottomNavClipper extends CustomClipper<Path> {
  static Path? _cachedLightPath;
  static Path? _cachedDarkPath;
  static Size? _cachedSize;

  @override
  Path getClip(Size size) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    // Use different cached paths for different themes
    if (_cachedSize == size) {
      if (isDark && _cachedDarkPath != null) {
        return _cachedDarkPath!;
      } else if (!isDark && _cachedLightPath != null) {
        return _cachedLightPath!;
      }
    }

    final path = Path();
    final radius =
        isDark ? 24.0 : 28.0; // Kurangi radius untuk seamless look di dark mode
    final centerCurveHeight =
        isDark ? 4.0 : 6.0; // Kurangi curve untuk seamless

    // Start from top-left
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge with theme-aware center curve
    final centerX = size.width / 2;
    final curveWidth =
        isDark ? 40.0 : 50.0; // Kurangi curve width untuk seamless

    path.lineTo(centerX - curveWidth, 0);
    path.quadraticBezierTo(centerX, centerCurveHeight, centerX + curveWidth, 0);

    // Continue to top-right
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Complete the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.close();

    // Cache based on theme
    if (isDark) {
      _cachedDarkPath = path;
    } else {
      _cachedLightPath = path;
    }
    _cachedSize = size;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

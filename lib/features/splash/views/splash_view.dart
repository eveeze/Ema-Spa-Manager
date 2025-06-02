import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/text_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    // Remove _setSystemUIOverlay() from here
  }

  void _initializeAnimations() {
    // Initialize animation controllers with refined durations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations with improved curves
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutQuart),
    );

    // Subtle pulsing animation for loading indicator
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    // Start animations with staggered delays for smooth sequence
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _rotateController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _pulseController.repeat(reverse: true);
  }

  void _setSystemUIOverlay(BuildContext context) {
    // Move this method to be called from build method
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Always light on splash
        systemNavigationBarColor:
            brightness == Brightness.dark
                ? ColorTheme.backgroundDark
                : ColorTheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ColorTheme.textPrimaryDark
        : Colors.white;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ColorTheme.textSecondaryDark
        : Colors.white.withValues(alpha: 0.9);
  }

  Color _getLoadingIndicatorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ColorTheme.primaryLightDark
        : Colors.white.withValues(alpha: 0.8);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();

    // Reset system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    // Call _setSystemUIOverlay here instead of in initState
    _setSystemUIOverlay(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorTheme.primary, ColorTheme.primaryDark],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern with theme-aware opacity
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/splash_bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.3 * _fadeAnimation.value,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content with responsive sizing
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced logo section with multiple animations
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _scaleAnimation,
                      _rotateAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Container(
                            width: isSmallScreen ? 180 : 225,
                            height: isSmallScreen ? 180 : 225,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Enhanced app name with theme-aware styling
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Main title with special text style
                          Text(
                            'Ema Mom Kids',
                            style: SpecialTextStyles.decorativeHeading.copyWith(
                              fontSize: isSmallScreen ? 28 : 36,
                              color: _getTextColor(context),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle with refined styling
                          Text(
                            'Baby Spa',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 28,
                              fontWeight: FontWeight.w400,
                              color: _getSecondaryTextColor(context),
                              letterSpacing: 2,
                              fontFamily: 'JosefinSans',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 60 : 100),

                  // Enhanced tagline with better typography
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Care, Healthy, and Healing',
                      textAlign: TextAlign.center,
                      style: SpecialTextStyles.appSubtitle.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: _getSecondaryTextColor(context),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced loading indicator with pulse animation
            Positioned(
              bottom: isSmallScreen ? 60 : 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getLoadingIndicatorColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: _getSecondaryTextColor(
                                context,
                              ).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Version info (optional, can be removed)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getSecondaryTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontFamily: 'JosefinSans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

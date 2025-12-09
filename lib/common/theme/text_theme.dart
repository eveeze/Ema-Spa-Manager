import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

// You can keep this M3Spacing class here or move it to its own file.
class M3Spacing {
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 16.0; // Medium (base)
  static const double lg = 24.0; // Large
  static const double xl = 32.0; // Extra large
  static const double xxl = 48.0; // Extra extra large
}

/// --- NEW: Typography Metrics Constants ---
/// Holds all the standard Material 3 type scale values for reuse.
class _M3TypographyMetrics {
  // Display
  static const double displayLargeSize = 57.0;
  static const double displayLargeHeight = 1.12; // 64px
  static const double displayLargeLetterSpacing = -0.25;

  static const double displayMediumSize = 45.0;
  static const double displayMediumHeight = 1.16; // 52px
  static const double displayMediumLetterSpacing = 0.0;

  static const double displaySmallSize = 36.0;
  static const double displaySmallHeight = 1.22; // 44px
  static const double displaySmallLetterSpacing = 0.0;

  // Headline
  static const double headlineLargeSize = 32.0;
  static const double headlineLargeHeight = 1.25; // 40px
  static const double headlineLargeLetterSpacing = 0.0;

  static const double headlineMediumSize = 28.0;
  static const double headlineMediumHeight = 1.29; // 36px
  static const double headlineMediumLetterSpacing = 0.0;

  static const double headlineSmallSize = 24.0;
  static const double headlineSmallHeight = 1.33; // 32px
  static const double headlineSmallLetterSpacing = 0.0;

  // Title
  static const double titleLargeSize = 22.0;
  static const double titleLargeHeight = 1.27; // 28px
  static const double titleLargeLetterSpacing = 0.0;

  static const double titleMediumSize = 16.0;
  static const double titleMediumHeight = 1.50; // 24px
  static const double titleMediumLetterSpacing = 0.15;

  static const double titleSmallSize = 14.0;
  static const double titleSmallHeight = 1.43; // 20px
  static const double titleSmallLetterSpacing = 0.1;

  // Body
  static const double bodyLargeSize = 16.0;
  static const double bodyLargeHeight = 1.50; // 24px
  static const double bodyLargeLetterSpacing = 0.5;

  static const double bodyMediumSize = 14.0;
  static const double bodyMediumHeight = 1.43; // 20px
  static const double bodyMediumLetterSpacing = 0.25;

  static const double bodySmallSize = 12.0;
  static const double bodySmallHeight = 1.33; // 16px
  static const double bodySmallLetterSpacing = 0.4;

  // Label
  static const double labelLargeSize = 14.0;
  static const double labelLargeHeight = 1.43; // 20px
  static const double labelLargeLetterSpacing = 0.1;

  static const double labelMediumSize = 12.0;
  static const double labelMediumHeight = 1.33; // 16px
  static const double labelMediumLetterSpacing = 0.5;

  static const double labelSmallSize = 11.0;
  static const double labelSmallHeight = 1.45; // 16px
  static const double labelSmallLetterSpacing = 0.5;
}

class TextThemes {
  // Font families
  static const String _contentFontFamily = 'JosefinSans';
  static const String _displayFontFamily = 'DeliusSwashCaps';

  // --- UPDATED: Main content text theme with proper M3 colors ---
  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: _M3TypographyMetrics.displayLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface, // Use M3 OnSurface for visibility
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displayLargeHeight,
      letterSpacing: _M3TypographyMetrics.displayLargeLetterSpacing,
    ),
    displayMedium: TextStyle(
      fontSize: _M3TypographyMetrics.displayMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displayMediumHeight,
      letterSpacing: _M3TypographyMetrics.displayMediumLetterSpacing,
    ),
    displaySmall: TextStyle(
      fontSize: _M3TypographyMetrics.displaySmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displaySmallHeight,
      letterSpacing: _M3TypographyMetrics.displaySmallLetterSpacing,
    ),
    headlineLarge: TextStyle(
      fontSize: _M3TypographyMetrics.headlineLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineLargeHeight,
      letterSpacing: _M3TypographyMetrics.headlineLargeLetterSpacing,
    ),
    headlineMedium: TextStyle(
      fontSize: _M3TypographyMetrics.headlineMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineMediumHeight,
      letterSpacing: _M3TypographyMetrics.headlineMediumLetterSpacing,
    ),
    headlineSmall: TextStyle(
      fontSize: _M3TypographyMetrics.headlineSmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineSmallHeight,
      letterSpacing: _M3TypographyMetrics.headlineSmallLetterSpacing,
    ),
    titleLarge: TextStyle(
      fontSize: _M3TypographyMetrics.titleLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleLargeHeight,
      letterSpacing: _M3TypographyMetrics.titleLargeLetterSpacing,
    ),
    titleMedium: TextStyle(
      fontSize: _M3TypographyMetrics.titleMediumSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleMediumHeight,
      letterSpacing: _M3TypographyMetrics.titleMediumLetterSpacing,
    ),
    titleSmall: TextStyle(
      fontSize: _M3TypographyMetrics.titleSmallSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleSmallHeight,
      letterSpacing: _M3TypographyMetrics.titleSmallLetterSpacing,
    ),
    bodyLarge: TextStyle(
      fontSize: _M3TypographyMetrics.bodyLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodyLargeHeight,
      letterSpacing: _M3TypographyMetrics.bodyLargeLetterSpacing,
    ),
    bodyMedium: TextStyle(
      fontSize: _M3TypographyMetrics.bodyMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodyMediumHeight,
      letterSpacing: _M3TypographyMetrics.bodyMediumLetterSpacing,
    ),
    bodySmall: TextStyle(
      fontSize: _M3TypographyMetrics.bodySmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceVariant, // Slightly muted for secondary text
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodySmallHeight,
      letterSpacing: _M3TypographyMetrics.bodySmallLetterSpacing,
    ),
    labelLarge: TextStyle(
      fontSize: _M3TypographyMetrics.labelLargeSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelLargeHeight,
      letterSpacing: _M3TypographyMetrics.labelLargeLetterSpacing,
    ),
    labelMedium: TextStyle(
      fontSize: _M3TypographyMetrics.labelMediumSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurface,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelMediumHeight,
      letterSpacing: _M3TypographyMetrics.labelMediumLetterSpacing,
    ),
    labelSmall: TextStyle(
      fontSize: _M3TypographyMetrics.labelSmallSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceVariant,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelSmallHeight,
      letterSpacing: _M3TypographyMetrics.labelSmallLetterSpacing,
    ),
  );

  // --- UPDATED: Dark theme with proper M3 dark colors ---
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: _M3TypographyMetrics.displayLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displayLargeHeight,
      letterSpacing: _M3TypographyMetrics.displayLargeLetterSpacing,
    ),
    displayMedium: TextStyle(
      fontSize: _M3TypographyMetrics.displayMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displayMediumHeight,
      letterSpacing: _M3TypographyMetrics.displayMediumLetterSpacing,
    ),
    displaySmall: TextStyle(
      fontSize: _M3TypographyMetrics.displaySmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _displayFontFamily,
      height: _M3TypographyMetrics.displaySmallHeight,
      letterSpacing: _M3TypographyMetrics.displaySmallLetterSpacing,
    ),
    headlineLarge: TextStyle(
      fontSize: _M3TypographyMetrics.headlineLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineLargeHeight,
      letterSpacing: _M3TypographyMetrics.headlineLargeLetterSpacing,
    ),
    headlineMedium: TextStyle(
      fontSize: _M3TypographyMetrics.headlineMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineMediumHeight,
      letterSpacing: _M3TypographyMetrics.headlineMediumLetterSpacing,
    ),
    headlineSmall: TextStyle(
      fontSize: _M3TypographyMetrics.headlineSmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.headlineSmallHeight,
      letterSpacing: _M3TypographyMetrics.headlineSmallLetterSpacing,
    ),
    titleLarge: TextStyle(
      fontSize: _M3TypographyMetrics.titleLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleLargeHeight,
      letterSpacing: _M3TypographyMetrics.titleLargeLetterSpacing,
    ),
    titleMedium: TextStyle(
      fontSize: _M3TypographyMetrics.titleMediumSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleMediumHeight,
      letterSpacing: _M3TypographyMetrics.titleMediumLetterSpacing,
    ),
    titleSmall: TextStyle(
      fontSize: _M3TypographyMetrics.titleSmallSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.titleSmallHeight,
      letterSpacing: _M3TypographyMetrics.titleSmallLetterSpacing,
    ),
    bodyLarge: TextStyle(
      fontSize: _M3TypographyMetrics.bodyLargeSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodyLargeHeight,
      letterSpacing: _M3TypographyMetrics.bodyLargeLetterSpacing,
    ),
    bodyMedium: TextStyle(
      fontSize: _M3TypographyMetrics.bodyMediumSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodyMediumHeight,
      letterSpacing: _M3TypographyMetrics.bodyMediumLetterSpacing,
    ),
    bodySmall: TextStyle(
      fontSize: _M3TypographyMetrics.bodySmallSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.m3OnSurfaceVariantDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.bodySmallHeight,
      letterSpacing: _M3TypographyMetrics.bodySmallLetterSpacing,
    ),
    labelLarge: TextStyle(
      fontSize: _M3TypographyMetrics.labelLargeSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelLargeHeight,
      letterSpacing: _M3TypographyMetrics.labelLargeLetterSpacing,
    ),
    labelMedium: TextStyle(
      fontSize: _M3TypographyMetrics.labelMediumSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelMediumHeight,
      letterSpacing: _M3TypographyMetrics.labelMediumLetterSpacing,
    ),
    labelSmall: TextStyle(
      fontSize: _M3TypographyMetrics.labelSmallSize,
      fontWeight: FontWeight.w500,
      color: ColorTheme.m3OnSurfaceVariantDark,
      fontFamily: _contentFontFamily,
      height: _M3TypographyMetrics.labelSmallHeight,
      letterSpacing: _M3TypographyMetrics.labelSmallLetterSpacing,
    ),
  );
}

// Special text styles for specific use cases
class SpecialTextStyles {
  // Font families (same as in TextThemes)
  static const String _contentFontFamily = 'JosefinSans';
  static const String _displayFontFamily = 'DeliusSwashCaps';

  // App title style for splash screen using DeliusSwashCaps
  static TextStyle get appTitle => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3Primary,
    fontFamily: _displayFontFamily,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static TextStyle get appTitleDark => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3PrimaryDark,
    fontFamily: _displayFontFamily,
    height: 1.0,
    letterSpacing: -0.5,
  );

  // Subtitle for splash screen
  static TextStyle get appSubtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3OnSurfaceVariant,
    fontFamily: _contentFontFamily,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle get appSubtitleDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3OnSurfaceVariantDark,
    fontFamily: _contentFontFamily,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Special decorative headings using DeliusSwashCaps
  static TextStyle get decorativeHeading => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3Primary,
    fontFamily: _displayFontFamily,
    height: 1.1,
    letterSpacing: 0,
  );

  static TextStyle get decorativeHeadingDark => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: ColorTheme.m3PrimaryDark,
    fontFamily: _displayFontFamily,
    height: 1.1,
    letterSpacing: 0,
  );

  // Button text with better contrast
  static TextStyle get buttonPrimary => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3OnPrimary,
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonPrimaryDark => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3OnPrimaryDark,
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSecondary => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3Primary,
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSecondaryDark => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3PrimaryDark,
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Card title with improved readability
  static TextStyle get cardTitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3OnSurface,
    fontFamily: _contentFontFamily,
    height: 1.3,
    letterSpacing: 0.15,
  );

  static TextStyle get cardTitleDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorTheme.m3OnSurfaceDark,
    fontFamily: _contentFontFamily,
    height: 1.3,
    letterSpacing: 0.15,
  );
}

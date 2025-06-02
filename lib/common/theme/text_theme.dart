// lib/common/theme/text_theme.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class TextThemes {
  // Font families
  static const String _contentFontFamily = 'JosefinSans';
  static const String _displayFontFamily = 'DeliusSwashCaps';

  // Improved line height factors for optimal readability
  static const double _displayHeight = 1.1;
  static const double _headingHeight = 1.25;
  static const double _bodyHeight = 1.6;
  static const double _labelHeight = 1.4;

  // Font size scale
  static const double _baseSize = 16.0;

  // Main content text theme using JosefinSans
  static final TextTheme textTheme = TextTheme(
    // Display styles - using DeliusSwashCaps for special titles
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight:
          FontWeight.w400, // DeliusSwashCaps works better with normal weight
      color: ColorTheme.textPrimary,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimary,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimary,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: 0,
    ),

    // Headline styles - using JosefinSans with improved contrast
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary, // Darker color for better readability
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0.15,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0.25,
    ),

    // Title styles - improved contrast
    titleLarge: TextStyle(
      fontSize: _baseSize,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary, // Using primary text color
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary, // Changed from secondary to primary
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.25,
    ),

    // Body styles - enhanced readability
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimary, // Primary color for better contrast
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),
    bodyMedium: TextStyle(
      fontSize: _baseSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimary, // Primary color for main content
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.15,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textSecondary, // Secondary for less important content
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),

    // Label styles - improved visibility
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary, // Primary for better readability
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500, // Reduced from w600 for better balance
      color: ColorTheme.textSecondary, // Secondary for subtle labels
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.8,
    ),
  );

  // Dark theme with improved contrast
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _displayFontFamily,
      height: _displayHeight,
      letterSpacing: 0,
    ),

    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0.15,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _headingHeight,
      letterSpacing: 0.25,
    ),

    titleLarge: TextStyle(
      fontSize: _baseSize,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.25,
    ),

    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),
    bodyMedium: TextStyle(
      fontSize: _baseSize,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.15,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ColorTheme.textSecondaryDark,
      fontFamily: _contentFontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textSecondaryDark,
      fontFamily: _contentFontFamily,
      height: _labelHeight,
      letterSpacing: 0.8,
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
    color: ColorTheme.primary,
    fontFamily: _displayFontFamily,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static TextStyle get appTitleDark => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w400,
    color: ColorTheme.primaryLightDark,
    fontFamily: _displayFontFamily,
    height: 1.0,
    letterSpacing: -0.5,
  );

  // Subtitle for splash screen
  static TextStyle get appSubtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorTheme.textSecondary,
    fontFamily: _contentFontFamily,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle get appSubtitleDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorTheme.textSecondaryDark,
    fontFamily: _contentFontFamily,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Special decorative headings using DeliusSwashCaps
  static TextStyle get decorativeHeading => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: ColorTheme.primary,
    fontFamily: _displayFontFamily,
    height: 1.1,
    letterSpacing: 0,
  );

  static TextStyle get decorativeHeadingDark => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: ColorTheme.primaryLightDark,
    fontFamily: _displayFontFamily,
    height: 1.1,
    letterSpacing: 0,
  );

  // Button text with better contrast
  static TextStyle get buttonPrimary => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.textInverse, // White text on colored button
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSecondary => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorTheme.primary, // Colored text on white/transparent button
    fontFamily: _contentFontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Card title with improved readability
  static TextStyle get cardTitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorTheme.textPrimary,
    fontFamily: _contentFontFamily,
    height: 1.3,
    letterSpacing: 0.15,
  );

  static TextStyle get cardTitleDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorTheme.textPrimaryDark,
    fontFamily: _contentFontFamily,
    height: 1.3,
    letterSpacing: 0.15,
  );
}

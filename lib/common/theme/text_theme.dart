import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class TextThemes {
  // Define constants for reusability
  static const String _fontFamily = 'JosefinSans';

  // Line height factors for better readability
  static const double _headingHeight = 1.2;
  static const double _bodyHeight = 1.5;
  static const double _labelHeight = 1.3;

  static final TextTheme textTheme = TextTheme(
    // Display styles - for the largest text elements
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700, // Bolder for better contrast
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: -0.25, // Tighter for large text
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: -0.15,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),

    // Headline styles - for section headers
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0.15,
    ),

    // Title styles - for UI component headers
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),

    // Body styles - for paragraph text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.5, // Looser for better readability in paragraphs
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textSecondary,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.4,
    ),

    // Label styles - for buttons, form fields, etc.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight:
          FontWeight
              .w600, // Slightly bolder for better visibility at small sizes
      color: ColorTheme.textSecondary,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
  );

  static final TextTheme darkTextTheme = TextTheme(
    // Display styles - for the largest text elements
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: -0.15,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),

    // Headline styles - for section headers
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _headingHeight,
      letterSpacing: 0.15,
    ),

    // Title styles - for UI component headers
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),

    // Body styles - for paragraph text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: ColorTheme.textSecondaryDark,
      fontFamily: _fontFamily,
      height: _bodyHeight,
      letterSpacing: 0.4,
    ),

    // Label styles - for buttons, form fields, etc.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ColorTheme.textPrimaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: ColorTheme.textSecondaryDark,
      fontFamily: _fontFamily,
      height: _labelHeight,
      letterSpacing: 0.5,
    ),
  );
}

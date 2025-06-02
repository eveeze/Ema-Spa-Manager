import 'package:flutter/material.dart';

class ColorTheme {
  // Primary palette - refined with smoother transitions
  static const Color primary = Color(
    0xFF9DCFE1,
  ); // Serene blue - main brand color
  static const Color primaryLight = Color(
    0xFFCFE9F2,
  ); // Light blue for hover states
  static const Color primaryDark = Color(
    0xFF2C7DA0,
  ); // Deep blue for pressed states
  static const Color secondary = Color(
    0xFF61A5C2,
  ); // Medium blue for secondary actions
  static const Color accent = Color(
    0xFFFFD6E0,
  ); // Soft pink for mother-related features

  // Background surfaces
  static const Color background = Color(
    0xFFFAFBFC,
  ); // Off-white for main background - easier on eyes
  static const Color surface = Color(0xFFF8F9FA); // Light gray for cards
  static const Color surfaceAlt = Color(
    0xFFF0F4F8,
  ); // Alternative card background for variety

  // Status colors - refined for better accessibility
  static const Color error = Color(
    0xFFE53935,
  ); // Less harsh red that's still clear
  static const Color success = Color(
    0xFF2ECC71,
  ); // More vibrant but calming green
  static const Color warning = Color(
    0xFFFFF1D0,
  ); // Soft yellow for baby features
  static const Color info = Color(0xFF2C7DA0); // Deep blue for important info

  // Typography colors - improved contrast for accessibility
  static const Color textPrimary = Color(
    0xFF212529,
  ); // Near-black for headings - improved contrast
  static const Color textSecondary = Color(
    0xFF495057,
  ); // Darker secondary text - better readability
  static const Color textTertiary = Color(
    0xFF6C757D,
  ); // Darker tertiary for better readability
  static const Color textInverse = Color(
    0xFFFFFFFF,
  ); // White text for dark backgrounds

  // Border and dividers - subtle refinements
  static const Color border = Color(0xFFE0E4E8); // Slightly visible borders
  static const Color borderFocus = Color(
    0xFF9DCFE1,
  ); // Border for focused elements
  static const Color divider = Color(0xFFEDF2F7); // Very subtle dividers

  // Feature-specific colors - more harmonious palette
  static const Color activeTagBackground = Color(
    0xFFE8F8F0,
  ); // Lighter green for active tags
  static const Color activeTagText = Color(
    0xFF2ECC71,
  ); // Green text for active tags
  static const Color inactiveTagBackground = Color(
    0xFFFBEAEA,
  ); // Lighter red for inactive tags
  static const Color inactiveTagText = Color(
    0xFFE53935,
  ); // Red text for inactive tags

  // UI component colors - now more cohesive
  static const Color fabBackground = Color(0xFF9DCFE1); // FAB matches primary
  static const Color tabActiveBackground = Color(
    0xFFCFE9F2,
  ); // Active tab background matches primaryLight
  static const Color cardBorder = Color(
    0xFFE0E4E8,
  ); // Card border matches main border
  static const Color cardShadow = Color(
    0x0A000000,
  ); // Very subtle shadow for depth
  static const Color categoryBorder = Color(
    0xFF61A5C2,
  ); // Category dropdown matches secondary

  // Interactive elements
  static const Color buttonPrimary = Color(0xFF9DCFE1); // Primary button color
  static const Color buttonSecondary = Color(
    0xFF61A5C2,
  ); // Secondary button color
  static const Color buttonDisabled = Color(
    0xFFE0E4E8,
  ); // Disabled button state
  static const Color inputBackground = Color(
    0xFFFFFFFF,
  ); // White background for input fields
  static const Color inputBorder = Color(0xFFE0E4E8); // Input border color
  static const Color inputFocus = Color(0xFF9DCFE1); // Input focus indicator

  // Bottom navigation colors - improved distinction
  static const Color bottomNavBackground = Color(
    0xFFFFFFFF,
  ); // White background
  static const Color bottomNavActive = Color(
    0xFF9DCFE1,
  ); // Active item matches primary
  static const Color bottomNavInactive = Color(
    0xFF6C757D,
  ); // Darker for better contrast

  // Dark Theme Colors - more refined
  static const Color primaryLightDark = Color(
    0xFF83B7CE,
  ); // Lighter shade for dark mode
  static const Color secondaryDark = Color(0xFF2C7DA0); // Dark Blue
  static const Color accentDark = Color(0xFFFFD6E0); // Soft Pink preserved
  static const Color backgroundDark = Color(
    0xFF121212,
  ); // Darker background following Material Design
  static const Color surfaceDark = Color(
    0xFF1E1E1E,
  ); // Dark surface with slight distinction
  static const Color errorDark = Color(
    0xFFEF5350,
  ); // Slightly lighter red for dark mode
  static const Color successDark = Color(0xFF4CD964); // Success green
  static const Color warningDark = Color(
    0xFFFFF1D0,
  ); // Warning yellow preserved
  static const Color infoDark = Color(0xFF9DCFE1); // Info blue

  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color textSecondaryDark = Color(
    0xFFE0E0E0,
  ); // Near white for better readability
  static const Color textTertiaryDark = Color(
    0xFFADBBCC,
  ); // Lighter gray with a hint of blue
  static const Color borderDark = Color(0xFF2D3748); // Darker subtle border
  static const Color dividerDark = Color(0xFF2D3748); // Dark divider
}

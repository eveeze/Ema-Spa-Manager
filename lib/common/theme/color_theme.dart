import 'package:flutter/material.dart';

class ColorTheme {
  // --- ORIGINAL LIGHT THEME COLORS (PRESERVED) ---
  static const Color primary = Color(0xFF2C7DA0);
  static const Color primaryLight = Color(0xFFCFE9F2);
  static const Color primaryDark = Color(0xFF014F64);
  static const Color secondary = Color(0xFF61A5C2);
  static const Color accent = Color(0xFFB94075);
  static const Color background = Color(0xFFF7F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F4F8);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF1E8449);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2C7DA0);

  // IMPROVED TEXT COLORS - Better visibility for light mode
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(
    0xFF1A1C1E,
  ); // Sama seperti textPrimary, bedanya di weight
  static const Color textTertiary = Color(
    0xFF1A1C1E,
  ); // Sama seperti textPrimary, bedanya di weight
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFDEE2E6);
  static const Color borderFocus = Color(0xFF2C7DA0);
  static const Color divider = Color(0xFFEDF2F7);
  static const Color activeTagBackground = Color(0xFFE8F5E9);
  static const Color activeTagText = Color(0xFF1E8449);
  static const Color inactiveTagBackground = Color(0xFFFBEAEA);
  static const Color inactiveTagText = Color(0xFFB71C1C);
  static const Color fabBackground = Color(0xFF2C7DA0);
  static const Color tabActiveBackground = Color(0xFFCFE9F2);
  static const Color cardBorder = Color(0xFFDEE2E6);
  static const Color cardShadow = Color(0x1A000000);
  static const Color categoryBorder = Color(0xFF61A5C2);
  static const Color buttonPrimary = Color(0xFF2C7DA0);
  static const Color buttonSecondary = Color(0xFF61A5C2);
  static const Color buttonDisabled = Color(0xFFE0E4E8);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFDEE2E6);
  static const Color inputFocus = Color(0xFF2C7DA0);
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavActive = Color(0xFF2C7DA0);
  static const Color bottomNavInactive = Color(0xFF6C757D);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);
  static const Color surfaceContainerHighest = Color(0xFFD1D5DB);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFDEE2E6);

  // --- ORIGINAL DARK THEME COLORS (PRESERVED) ---
  static const Color primaryLightDark = Color(0xFF83B7CE);
  static const Color secondaryDark = Color(0xFFADC8D5);
  static const Color accentDark = Color(0xFFDAA7BC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningDark = Color(0xFFFFF59D);
  static const Color infoDark = Color(0xFF83B7CE);
  static const Color textPrimaryDark = Color(0xFFE3E3E3);
  static const Color textSecondaryDark = Color(0xFFC4C7C5);
  static const Color textTertiaryDark = Color(0xFF8E9093);
  static const Color borderDark = Color(0xFF444746);
  static const Color dividerDark = Color(0xFF2D3748);
  static const Color onSurfaceVariant = Color(0xFF40484B);
  static const Color surfaceVariantDark = Color(0xFF40484B);
  static const Color onSurfaceVariantDark = Color(0xFFC0C8CB);
  static const Color surfaceContainerDark = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighDark = Color(0xFF353535);
  static const Color surfaceContainerHighestDark = Color(0xFF404040);
  static const Color surfaceBrightDark = Color(0xFF424242);
  static const Color surfaceDimDark = Color(0xFF121212);

  // M3 Light Palette - IMPROVED VARIANTS
  static const Color m3Primary = Color(0xFF006782);
  static const Color m3OnPrimary = Color(0xFFFFFFFF);
  static const Color m3PrimaryContainer = Color(0xFFBDE9FF);
  static const Color m3OnPrimaryContainer = Color(0xFF001F29);

  static const Color m3Secondary = Color(0xFF4C626B);
  static const Color m3OnSecondary = Color(0xFFFFFFFF);
  static const Color m3SecondaryContainer = Color(0xFFCFE6F1);
  static const Color m3OnSecondaryContainer = Color(0xFF071E26);

  static const Color m3Error = Color(0xFFBA1A1A);
  static const Color m3OnError = Color(0xFFFFFFFF);
  static const Color m3ErrorContainer = Color(0xFFFFDAD6);
  static const Color m3OnErrorContainer = Color(0xFF410002);

  static const Color m3Background = Color(0xFFFBFCFD);
  static const Color m3OnBackground = Color(0xFF191C1E);
  static const Color m3Surface = Color(0xFFFBFCFD);
  static const Color m3OnSurface = Color(0xFF191C1E);

  static const Color m3SurfaceVariant = Color(0xFFDCE4E8);

  // ✅ FIX: harus muted, jangan sama dengan onSurface
  static const Color m3OnSurfaceVariant = Color(0xFF40484B);

  // ✅ FIX: outline jangan gelap banget
  static const Color m3Outline = Color(0xFF6F797D);

  static const Color m3OutlineVariant = Color(0xFFC0C8CC);

  // M3 Dark Palette
  static const Color m3PrimaryDark = Color(0xFF65D2FF);
  static const Color m3OnPrimaryDark = Color(0xFF003545);
  static const Color m3PrimaryContainerDark = Color(0xFF004D63);
  static const Color m3OnPrimaryContainerDark = Color(0xFFBDE9FF);
  static const Color m3SecondaryDark = Color(0xFFB4CAD5);
  static const Color m3OnSecondaryDark = Color(0xFF1E333C);
  static const Color m3SecondaryContainerDark = Color(0xFF354A53);
  static const Color m3OnSecondaryContainerDark = Color(0xFFCFE6F1);
  static const Color m3ErrorDark = Color(0xFFFFB4AB);
  static const Color m3OnErrorDark = Color(0xFF690005);
  static const Color m3BackgroundDark = Color(0xFF191C1E);
  static const Color m3OnBackgroundDark = Color(0xFFE1E2E4);
  static const Color m3SurfaceDark = Color(0xFF191C1E);
  static const Color m3OnSurfaceDark = Color(0xFFE1E2E4);
  static const Color m3SurfaceVariantDark = Color(0xFF40484C);
  static const Color m3OnSurfaceVariantDark = Color(0xFFC0C8CC);
  static const Color m3OutlineDark = Color(0xFF8A9296);
  static const Color m3SurfaceContainerDark = Color(0xFF2A2A2A);
}

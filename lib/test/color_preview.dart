import 'package:flutter/material.dart';

class ColorTheme {
  // Light Theme Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFEEF2FF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF6366F1);
  static const Color accentDark = Color(0xFF312E81);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color successDark = Color(0xFF22C55E);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color infoDark = Color(0xFF3B82F6);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF374151);
}

class ColorPreviewScreen extends StatelessWidget {
  const ColorPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColors = {
      'Primary': ColorTheme.primary,
      'Secondary': ColorTheme.secondary,
      'Accent': ColorTheme.accent,
      'Background': ColorTheme.background,
      'Surface': ColorTheme.surface,
      'Error': ColorTheme.error,
      'Success': ColorTheme.success,
      'Warning': ColorTheme.warning,
      'Info': ColorTheme.info,
      'Text Primary': ColorTheme.textPrimary,
      'Text Secondary': ColorTheme.textSecondary,
      'Text Tertiary': ColorTheme.textTertiary,
      'Border': ColorTheme.border,
      'Divider': ColorTheme.divider,
    };

    final darkColors = {
      'Primary': ColorTheme.primaryDark,
      'Secondary': ColorTheme.secondaryDark,
      'Accent': ColorTheme.accentDark,
      'Background': ColorTheme.backgroundDark,
      'Surface': ColorTheme.surfaceDark,
      'Error': ColorTheme.errorDark,
      'Success': ColorTheme.successDark,
      'Warning': ColorTheme.warningDark,
      'Info': ColorTheme.infoDark,
      'Text Primary': ColorTheme.textPrimaryDark,
      'Text Secondary': ColorTheme.textSecondaryDark,
      'Text Tertiary': ColorTheme.textTertiaryDark,
      'Border': ColorTheme.borderDark,
      'Divider': ColorTheme.dividerDark,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Theme Preview'),
        backgroundColor: ColorTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '🌞 Light Theme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...lightColors.entries.map(
            (entry) => ColorTile(name: entry.key, color: entry.value),
          ),
          const SizedBox(height: 24),
          const Text(
            '🌙 Dark Theme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...darkColors.entries.map(
            (entry) => ColorTile(name: entry.key, color: entry.value),
          ),
        ],
      ),
    );
  }
}

class ColorTile extends StatelessWidget {
  final String name;
  final Color color;

  const ColorTile({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            Text(
              '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

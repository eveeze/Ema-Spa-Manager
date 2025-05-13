// lib/common/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

enum AppButtonType { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final bool iconPosition; // true = kiri, false = kanan

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.icon,
    this.iconPosition = true,
  });

  @override
  Widget build(BuildContext context) {
    return _buildButton();
  }

  Widget _buildButton() {
    switch (type) {
      case AppButtonType.primary:
        return _buildElevatedButton();
      case AppButtonType.secondary:
        return _buildSecondaryButton();
      case AppButtonType.outline:
        return _buildOutlinedButton();
      case AppButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primary,
          foregroundColor: Colors.white,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: ColorTheme.primary.withValues(alpha: 0.4),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.secondary,
          foregroundColor: Colors.white,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: ColorTheme.secondary.withValues(alpha: 0.4),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.primary,
          side: BorderSide(color: ColorTheme.primary, width: 1.5),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _buildButtonContent(ColorTheme.primary),
      ),
    );
  }

  Widget _buildTextButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: ColorTheme.primary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          overlayColor: ColorTheme.primaryLight.withValues(alpha: 0.2),
        ),
        child: _buildButtonContent(ColorTheme.primary),
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return _buildLoadingIndicator(color);
    } else if (icon != null) {
      return _buildTextWithIcon(color);
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
    }
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: size == AppButtonSize.small ? 16 : 20,
      width: size == AppButtonSize.small ? 16 : 20,
      child: CircularProgressIndicator(
        strokeWidth: size == AppButtonSize.small ? 2 : 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildTextWithIcon(Color color) {
    final iconGap = size == AppButtonSize.large ? 10.0 : 8.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconPosition) ...[
          Icon(icon, size: _getIconSize()),
          SizedBox(width: iconGap),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        if (!iconPosition) ...[
          SizedBox(width: iconGap),
          Icon(icon, size: _getIconSize()),
        ],
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }
}

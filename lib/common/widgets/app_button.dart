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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          side: BorderSide(color: ColorTheme.primary),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.w600),
      );
    }
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildTextWithIcon(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconPosition) ...[
          Icon(icon, size: _getIconSize()),
          SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!iconPosition) ...[
          SizedBox(width: 8),
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

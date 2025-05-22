// lib/common/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

enum AppButtonType { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(),
        );
      },
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: _buildButtonByType(),
      ),
    );
  }

  Widget _buildButtonByType() {
    switch (widget.type) {
      case AppButtonType.primary:
        return _buildPrimaryButton();
      case AppButtonType.secondary:
        return _buildSecondaryButton();
      case AppButtonType.outline:
        return _buildOutlinedButton();
      case AppButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorTheme.primary, ColorTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.primary.withValues(alpha: 0.3),
            blurRadius: _isPressed ? 8 : 12,
            offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
            spreadRadius: _isPressed ? 0 : 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            padding: _getPadding(),
            alignment: Alignment.center,
            child: _buildButtonContent(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorTheme.secondary,
            ColorTheme.secondary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.secondary.withValues(alpha: 0.25),
            blurRadius: _isPressed ? 6 : 10,
            offset: _isPressed ? const Offset(0, 2) : const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            padding: _getPadding(),
            alignment: Alignment.center,
            child: _buildButtonContent(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: BoxDecoration(
        color:
            _isPressed
                ? ColorTheme.primary.withValues(alpha: 0.05)
                : Colors.transparent,
        border: Border.all(color: ColorTheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow:
            _isPressed
                ? []
                : [
                  BoxShadow(
                    color: ColorTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          splashColor: ColorTheme.primary.withValues(alpha: 0.1),
          highlightColor: ColorTheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: _getPadding(),
            alignment: Alignment.center,
            child: _buildButtonContent(ColorTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: BoxDecoration(
        color:
            _isPressed
                ? ColorTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          splashColor: ColorTheme.primary.withValues(alpha: 0.12),
          highlightColor: ColorTheme.primary.withValues(alpha: 0.06),
          child: Container(
            padding: _getPadding(),
            alignment: Alignment.center,
            child: _buildButtonContent(ColorTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (widget.isLoading) {
      return _buildLoadingIndicator(color);
    } else if (widget.icon != null) {
      return _buildTextWithIcon(color);
    } else {
      return _buildText(color);
    }
  }

  Widget _buildText(Color color) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: _getFontWeight(),
        letterSpacing: _getLetterSpacing(),
        color: color,
        height: 1.2,
      ),
      child: Text(widget.text),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: _getLoadingSize(),
      width: _getLoadingSize(),
      child: CircularProgressIndicator(
        strokeWidth: _getLoadingStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeCap: StrokeCap.round,
      ),
    );
  }

  Widget _buildTextWithIcon(Color color) {
    final iconGap = _getIconGap();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconPosition) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(widget.icon, size: _getIconSize(), color: color),
          ),
          SizedBox(width: iconGap),
        ],
        Flexible(child: _buildText(color)),
        if (!widget.iconPosition) ...[
          SizedBox(width: iconGap),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(widget.icon, size: _getIconSize(), color: color),
          ),
        ],
      ],
    );
  }

  // Dimension and styling methods
  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.large:
        return 16;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 17;
    }
  }

  FontWeight _getFontWeight() {
    return widget.type == AppButtonType.text
        ? FontWeight.w500
        : FontWeight.w600;
  }

  double _getLetterSpacing() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 0.2;
      case AppButtonSize.medium:
        return 0.3;
      case AppButtonSize.large:
        return 0.4;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  double _getIconGap() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  double _getLoadingStrokeWidth() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 2;
      case AppButtonSize.medium:
        return 2.5;
      case AppButtonSize.large:
        return 3;
    }
  }
}

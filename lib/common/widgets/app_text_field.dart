// lib/common/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

enum TextFieldSize { small, medium, large }

class AppTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextFieldSize size;
  final bool isRequired;
  final bool enabled;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.size = TextFieldSize.medium,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Use Theme.of(context) instead of ThemeController for consistency
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[_buildLabel(isDark), const SizedBox(height: 8)],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _getContainerDecoration(isDark, isError),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            readOnly: readOnly,
            onChanged: onChanged,
            onTap: onTap,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            autofocus: autofocus,
            focusNode: focusNode,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            inputFormatters: inputFormatters,
            validator: validator,
            cursorColor: _getCursorColor(isDark),
            cursorWidth: 2.0,
            cursorRadius: const Radius.circular(1),
            style: _getTextStyle(isDark),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: _getHintStyle(isDark),
              helperText: helperText,
              helperStyle: _getHelperStyle(isDark),
              errorText: errorText,
              errorStyle: _getErrorStyle(isDark),
              contentPadding: _getContentPadding(),
              filled: true,
              fillColor: _getFillColor(isDark),
              border: _getBorder(isDark, isError: false),
              enabledBorder: _getBorder(isDark, isError: false),
              focusedBorder: _getBorder(isDark, isFocused: true),
              errorBorder: _getBorder(isDark, isError: true),
              focusedErrorBorder: _getBorder(
                isDark,
                isError: true,
                isFocused: true,
              ),
              prefixIcon:
                  prefix != null ? _buildIconWrapper(prefix!, isDark) : null,
              suffixIcon:
                  suffix != null ? _buildIconWrapper(suffix!, isDark) : null,
              isDense: size == TextFieldSize.small,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
        ),
        if (helperText != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: _buildHelperText(isDark),
          ),
      ],
    );
  }

  Widget _buildLabel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
      child: Row(
        children: [
          Text(label!, style: _getLabelStyle(isDark)),
          if (isRequired)
            Text(
              " *",
              style: _getLabelStyle(isDark).copyWith(
                color: isDark ? ColorTheme.errorDark : ColorTheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(bool isDark) {
    return Text(helperText!, style: _getHelperTextStyle(isDark));
  }

  Widget _buildIconWrapper(Widget icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: IconTheme(
        data: IconThemeData(color: _getIconColor(isDark), size: _getIconSize()),
        child: icon,
      ),
    );
  }

  // Container decoration with proper shadow for both themes
  BoxDecoration _getContainerDecoration(bool isDark, bool isError) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        if (enabled && !isError)
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : ColorTheme.primary.withValues(alpha: 0.08),
            blurRadius: isDark ? 6 : 8,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  // Improved color methods with proper light/dark mode support
  Color _getCursorColor(bool isDark) {
    return isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;
  }

  Color _getIconColor(bool isDark) {
    if (!enabled) {
      return isDark
          ? ColorTheme.textTertiaryDark.withValues(alpha: 0.5)
          : ColorTheme.textTertiary.withValues(alpha: 0.5);
    }
    return isDark ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;
  }

  Color _getFillColor(bool isDark) {
    if (!enabled) {
      return isDark
          ? ColorTheme.surfaceDark.withValues(alpha: 0.3)
          : ColorTheme.surface.withValues(alpha: 0.5);
    } else if (readOnly) {
      return isDark
          ? ColorTheme.surfaceDark.withValues(alpha: 0.7)
          : ColorTheme.surfaceAlt;
    } else {
      return isDark ? ColorTheme.surfaceDark : Colors.white;
    }
  }

  OutlineInputBorder _getBorder(
    bool isDark, {
    bool isError = false,
    bool isFocused = false,
  }) {
    Color borderColor;
    double borderWidth = 1.0;

    if (isError) {
      borderColor = isDark ? ColorTheme.errorDark : ColorTheme.error;
      borderWidth = isFocused ? 2.0 : 1.0;
    } else if (isFocused) {
      borderColor = isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;
      borderWidth = 2.0;
    } else if (!enabled) {
      borderColor =
          isDark
              ? ColorTheme.borderDark.withValues(alpha: 0.5)
              : ColorTheme.border.withValues(alpha: 0.5);
    } else {
      borderColor = isDark ? ColorTheme.borderDark : ColorTheme.border;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  TextStyle _getLabelStyle(bool isDark) {
    final baseColor =
        isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;

    switch (size) {
      case TextFieldSize.small:
        return TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: baseColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.medium:
        return TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: baseColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.large:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: baseColor,
          fontFamily: 'JosefinSans',
        );
    }
  }

  TextStyle _getHelperTextStyle(bool isDark) {
    return TextStyle(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w400,
      color:
          isDark
              ? ColorTheme.textTertiaryDark.withValues(alpha: 0.8)
              : ColorTheme.textTertiary.withValues(alpha: 0.8),
      fontFamily: 'JosefinSans',
    );
  }

  TextStyle _getTextStyle(bool isDark) {
    Color textColor;
    if (!enabled) {
      textColor =
          isDark ? ColorTheme.textTertiaryDark : ColorTheme.textTertiary;
    } else {
      textColor = isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
    }

    switch (size) {
      case TextFieldSize.small:
        return TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.medium:
        return TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.large:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
    }
  }

  TextStyle _getHintStyle(bool isDark) {
    final hintColor =
        isDark
            ? ColorTheme.textTertiaryDark.withValues(alpha: 0.7)
            : ColorTheme.textTertiary.withValues(alpha: 0.7);

    switch (size) {
      case TextFieldSize.small:
        return TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color: hintColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.medium:
        return TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color: hintColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.large:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color: hintColor,
          fontFamily: 'JosefinSans',
        );
    }
  }

  TextStyle _getHelperStyle(bool isDark) {
    return TextStyle(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: isDark ? ColorTheme.textTertiaryDark : ColorTheme.textTertiary,
      fontFamily: 'JosefinSans',
    );
  }

  TextStyle _getErrorStyle(bool isDark) {
    return TextStyle(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: isDark ? ColorTheme.errorDark : ColorTheme.error,
      fontFamily: 'JosefinSans',
    );
  }

  EdgeInsets _getContentPadding() {
    switch (size) {
      case TextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case TextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 16);
      case TextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
    }
  }

  double _getHelperFontSize() {
    switch (size) {
      case TextFieldSize.small:
        return 11;
      case TextFieldSize.medium:
        return 12;
      case TextFieldSize.large:
        return 13;
    }
  }

  double _getIconSize() {
    switch (size) {
      case TextFieldSize.small:
        return 18;
      case TextFieldSize.medium:
        return 20;
      case TextFieldSize.large:
        return 22;
    }
  }
}

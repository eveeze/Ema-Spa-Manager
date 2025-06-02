// lib/common/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/text_theme.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _buildLabel(context, isDark),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (enabled && !isError && !isDark)
                BoxShadow(
                  color: ColorTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              if (enabled && !isError && isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
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
            cursorColor:
                isDark ? ColorTheme.primaryLightDark : ColorTheme.primary,
            cursorWidth: 2.0,
            cursorRadius: const Radius.circular(1),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: _getHintStyle(context, isDark),
              helperText: helperText,
              helperStyle: _getHelperStyle(context, isDark),
              errorText: errorText,
              errorStyle: _getErrorStyle(context, isDark),
              contentPadding: _getContentPadding(),
              filled: true,
              fillColor: _getFillColor(context, isDark),
              border: _getBorder(context, isDark, isError: false),
              enabledBorder: _getBorder(context, isDark, isError: false),
              focusedBorder: _getBorder(context, isDark, isFocused: true),
              errorBorder: _getBorder(context, isDark, isError: true),
              focusedErrorBorder: _getBorder(
                context,
                isDark,
                isError: true,
                isFocused: true,
              ),
              prefixIcon:
                  prefix != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: IconTheme(
                          data: IconThemeData(
                            color:
                                isDark
                                    ? ColorTheme.textSecondaryDark
                                    : ColorTheme.textSecondary,
                            size: _getIconSize(),
                          ),
                          child: prefix!,
                        ),
                      )
                      : null,
              suffixIcon:
                  suffix != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: IconTheme(
                          data: IconThemeData(
                            color:
                                isDark
                                    ? ColorTheme.textSecondaryDark
                                    : ColorTheme.textSecondary,
                            size: _getIconSize(),
                          ),
                          child: suffix!,
                        ),
                      )
                      : null,
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
            style: _getTextStyle(context, isDark),
          ),
        ),
        if (helperText != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: _buildHelperText(context, isDark),
          ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, bool isDark) {
    Theme.of(context);
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
      child: Row(
        children: [
          Text(label!, style: _getLabelStyle(textTheme, isDark)),
          if (isRequired)
            Text(
              " *",
              style: _getLabelStyle(textTheme, isDark).copyWith(
                color: isDark ? ColorTheme.errorDark : ColorTheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(BuildContext context, bool isDark) {
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    return Text(helperText!, style: _getHelperTextStyle(textTheme, isDark));
  }

  // Enhanced styling methods using TextThemes
  TextStyle _getLabelStyle(TextTheme textTheme, bool isDark) {
    switch (size) {
      case TextFieldSize.small:
        return textTheme.labelMedium!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color:
              isDark
                  ? ColorTheme.textPrimaryDark.withValues(alpha: 0.9)
                  : ColorTheme.textPrimary.withValues(alpha: 0.9),
        );
      case TextFieldSize.medium:
        return textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color:
              isDark
                  ? ColorTheme.textPrimaryDark.withValues(alpha: 0.9)
                  : ColorTheme.textPrimary.withValues(alpha: 0.9),
        );
      case TextFieldSize.large:
        return textTheme.titleSmall!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color:
              isDark
                  ? ColorTheme.textPrimaryDark.withValues(alpha: 0.9)
                  : ColorTheme.textPrimary.withValues(alpha: 0.9),
        );
    }
  }

  TextStyle _getHelperTextStyle(TextTheme textTheme, bool isDark) {
    return textTheme.bodySmall!.copyWith(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w400,
      color:
          isDark
              ? ColorTheme.textTertiaryDark.withValues(alpha: 0.8)
              : ColorTheme.textTertiary.withValues(alpha: 0.8),
    );
  }

  Color _getFillColor(BuildContext context, bool isDark) {
    if (!enabled) {
      return isDark
          ? ColorTheme.borderDark.withValues(alpha: 0.3)
          : ColorTheme.border.withValues(alpha: 0.3);
    } else if (readOnly) {
      return isDark ? ColorTheme.surfaceDark : ColorTheme.surfaceAlt;
    } else {
      return isDark ? ColorTheme.surfaceDark : Colors.white;
    }
  }

  OutlineInputBorder _getBorder(
    BuildContext context,
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
    } else {
      borderColor = isDark ? ColorTheme.borderDark : ColorTheme.border;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  TextStyle _getTextStyle(BuildContext context, bool isDark) {
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    switch (size) {
      case TextFieldSize.small:
        return textTheme.bodySmall!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              enabled
                  ? (isDark
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary)
                  : (isDark
                      ? ColorTheme.textTertiaryDark
                      : ColorTheme.textTertiary),
        );
      case TextFieldSize.medium:
        return textTheme.bodyMedium!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              enabled
                  ? (isDark
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary)
                  : (isDark
                      ? ColorTheme.textTertiaryDark
                      : ColorTheme.textTertiary),
        );
      case TextFieldSize.large:
        return textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              enabled
                  ? (isDark
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary)
                  : (isDark
                      ? ColorTheme.textTertiaryDark
                      : ColorTheme.textTertiary),
        );
    }
  }

  TextStyle _getHintStyle(BuildContext context, bool isDark) {
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    switch (size) {
      case TextFieldSize.small:
        return textTheme.bodySmall!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              isDark
                  ? ColorTheme.textTertiaryDark.withValues(alpha: 0.7)
                  : ColorTheme.textTertiary.withValues(alpha: 0.7),
        );
      case TextFieldSize.medium:
        return textTheme.bodyMedium!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              isDark
                  ? ColorTheme.textTertiaryDark.withValues(alpha: 0.7)
                  : ColorTheme.textTertiary.withValues(alpha: 0.7),
        );
      case TextFieldSize.large:
        return textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color:
              isDark
                  ? ColorTheme.textTertiaryDark.withValues(alpha: 0.7)
                  : ColorTheme.textTertiary.withValues(alpha: 0.7),
        );
    }
  }

  TextStyle _getHelperStyle(BuildContext context, bool isDark) {
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    return textTheme.bodySmall!.copyWith(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: isDark ? ColorTheme.textTertiaryDark : ColorTheme.textTertiary,
    );
  }

  TextStyle _getErrorStyle(BuildContext context, bool isDark) {
    final textTheme = isDark ? TextThemes.darkTextTheme : TextThemes.textTheme;

    return textTheme.bodySmall!.copyWith(
      fontSize: _getHelperFontSize(),
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: isDark ? ColorTheme.errorDark : ColorTheme.error,
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

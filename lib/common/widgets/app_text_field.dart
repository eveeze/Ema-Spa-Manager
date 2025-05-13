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
    final isError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _buildLabel(),
          const SizedBox(
            height: 8,
          ), // Increased spacing for better visual hierarchy
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ), // Slightly more rounded corners
            boxShadow: [
              if (enabled && !isError)
                BoxShadow(
                  color: ColorTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 4,
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
            cursorColor: ColorTheme.primary, // Matching cursor to brand color
            cursorWidth: 1.5, // Slightly thinner cursor for elegance
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: ColorTheme.textTertiary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
              helperText: helperText,
              helperStyle: TextStyle(
                fontSize: _getHelperFontSize(),
                color: ColorTheme.textTertiary,
              ),
              errorText: errorText,
              errorStyle: TextStyle(
                fontSize: _getHelperFontSize(),
                color: ColorTheme.error,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: _getContentPadding(),
              filled: true,
              fillColor: _getFillColor(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorTheme.border, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorTheme.border, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorTheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: ColorTheme.error.withValues(alpha: 0.8),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorTheme.error, width: 1.5),
              ),
              prefixIcon:
                  prefix != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: prefix,
                      )
                      : null,
              suffixIcon:
                  suffix != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: suffix,
                      )
                      : null,
              isDense: size == TextFieldSize.small,
              // Add subtle internal padding for icons
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
            ),
            style: TextStyle(
              fontSize: _getFontSize(),
              color: enabled ? ColorTheme.textPrimary : ColorTheme.textTertiary,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w500,
              letterSpacing:
                  0.2, // Slightly increased letter spacing for better readability
            ),
          ),
        ),
        if (helperText != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: _buildHelperText(),
          ),
      ],
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
      child: Row(
        children: [
          Text(
            label!,
            style: TextStyle(
              fontSize: _getLabelFontSize(),
              fontWeight: FontWeight.w600, // Slightly bolder
              color: ColorTheme.textPrimary.withValues(alpha: 0.85),
              fontFamily: 'JosefinSans',
              letterSpacing: 0.1, // Subtle letter spacing
            ),
          ),
          if (isRequired)
            Text(
              " *",
              style: TextStyle(
                fontSize: _getLabelFontSize(),
                fontWeight: FontWeight.w600,
                color: ColorTheme.error,
                fontFamily: 'JosefinSans',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText() {
    return Text(
      helperText!,
      style: TextStyle(
        fontSize: _getHelperFontSize(),
        color: ColorTheme.textTertiary.withValues(alpha: 0.8),
        fontFamily: 'JosefinSans',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Color _getFillColor() {
    if (!enabled) {
      return ColorTheme.border.withValues(
        alpha: 0.3,
      ); // Softer disabled background
    } else if (readOnly) {
      return ColorTheme.background; // Light background for read-only
    } else {
      return Colors.white; // Bright white for editable
    }
  }

  EdgeInsets _getContentPadding() {
    switch (size) {
      case TextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
      case TextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
      case TextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 18);
    }
  }

  double _getFontSize() {
    switch (size) {
      case TextFieldSize.small:
        return 12;
      case TextFieldSize.medium:
        return 14;
      case TextFieldSize.large:
        return 16;
    }
  }

  double _getLabelFontSize() {
    switch (size) {
      case TextFieldSize.small:
        return 12;
      case TextFieldSize.medium:
        return 14;
      case TextFieldSize.large:
        return 14;
    }
  }

  double _getHelperFontSize() {
    switch (size) {
      case TextFieldSize.small:
        return 10;
      case TextFieldSize.medium:
        return 11;
      case TextFieldSize.large:
        return 12;
    }
  }
}

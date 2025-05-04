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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[_buildLabel(), SizedBox(height: 6)],
        TextField(
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
          onSubmitted: onSubmitted,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: ColorTheme.textTertiary),
            helperText: helperText,
            errorText: errorText,
            contentPadding: _getContentPadding(),
            filled: true,
            fillColor:
                enabled
                    ? Colors.white
                    : ColorTheme.border.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorTheme.error, width: 2),
            ),
            prefixIcon: prefix,
            suffixIcon: suffix,
            isDense: size == TextFieldSize.small,
          ),
          style: TextStyle(
            fontSize: _getFontSize(),
            color: ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
          ),
        ),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: _getLabelFontSize(),
            fontWeight: FontWeight.w500,
            color: ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: TextStyle(
              fontSize: _getLabelFontSize(),
              fontWeight: FontWeight.w500,
              color: ColorTheme.error,
              fontFamily: 'JosefinSans',
            ),
          ),
      ],
    );
  }

  EdgeInsets _getContentPadding() {
    switch (size) {
      case TextFieldSize.small:
        return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case TextFieldSize.medium:
        return EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case TextFieldSize.large:
        return EdgeInsets.symmetric(horizontal: 16, vertical: 16);
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
}

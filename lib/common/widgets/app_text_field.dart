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

  // Baru
  final Color? labelColor;
  final Color? requiredColor;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final Iterable<String>? autofillHints;

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
    this.labelColor,
    this.requiredColor,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
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
              style: textStyle ?? _getTextStyle(isDark),
              textAlign: textAlign,
              autofillHints: autofillHints,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: _getHintStyle(isDark),
                helperText: helperText,
                helperStyle: _getHelperStyle(isDark),
                errorText: null,
                errorStyle: null,
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
        ),
        if (errorText != null)
          Container(
            margin: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: _getErrorBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _getErrorBorderColor(isDark),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: _getErrorIconSize(),
                  color: _getErrorColor(isDark),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(errorText!, style: _getErrorStyle(isDark)),
                ),
              ],
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

  // ————— Support methods below —————

  Widget _buildLabel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
      child: Row(
        children: [
          Text(label!, style: _getLabelStyle(isDark)),
          if (isRequired)
            Text(
              " *",
              style: _getLabelStyle(
                isDark,
              ).copyWith(color: _getRequiredColor(isDark)),
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

  BoxDecoration _getContainerDecoration(bool isDark, bool isError) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        if (enabled && !isError)
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.4)
                    : ColorTheme.primary.withOpacity(0.08),
            blurRadius: isDark ? 6 : 8,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  Color _getCursorColor(bool isDark) =>
      isDark ? ColorTheme.primaryLightDark : ColorTheme.primary;
  Color _getIconColor(bool isDark) =>
      isDark ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;
  Color _getLabelColor(bool isDark) =>
      labelColor ??
      (isDark ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary);
  Color _getRequiredColor(bool isDark) =>
      requiredColor ?? (isDark ? ColorTheme.errorDark : ColorTheme.error);
  Color _getFillColor(bool isDark) {
    if (!enabled) {
      return isDark
          ? ColorTheme.surfaceDark.withOpacity(0.3)
          : ColorTheme.surface.withOpacity(0.5);
    } else if (readOnly) {
      return isDark
          ? ColorTheme.surfaceDark.withOpacity(0.7)
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
    } else {
      borderColor = isDark ? ColorTheme.borderDark : ColorTheme.border;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  TextStyle _getLabelStyle(bool isDark) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _getLabelColor(isDark),
    fontFamily: 'JosefinSans',
  );

  TextStyle _getHelperTextStyle(bool isDark) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color:
        isDark
            ? ColorTheme.textTertiaryDark.withOpacity(0.8)
            : ColorTheme.textTertiary.withOpacity(0.8),
    fontFamily: 'JosefinSans',
  );

  TextStyle _getTextStyle(bool isDark) {
    // Warna teks input yang terlihat jelas
    final Color textColor = isDark ? Colors.white : Colors.black;

    switch (size) {
      case TextFieldSize.small:
        return TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.medium:
        return TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
      case TextFieldSize.large:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          height: 1.5,
          color: textColor,
          fontFamily: 'JosefinSans',
        );
    }
  }

  TextStyle _getHintStyle(bool isDark) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color:
        isDark
            ? ColorTheme.textTertiaryDark.withOpacity(0.7)
            : ColorTheme.textTertiary.withOpacity(0.7),
    fontFamily: 'JosefinSans',
  );

  TextStyle _getHelperStyle(bool isDark) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: isDark ? ColorTheme.textTertiaryDark : ColorTheme.textTertiary,
    fontFamily: 'JosefinSans',
  );

  TextStyle _getErrorStyle(bool isDark) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: _getErrorColor(isDark),
    fontFamily: 'JosefinSans',
    letterSpacing: 0.1,
  );

  Color _getErrorColor(bool isDark) =>
      isDark ? ColorTheme.errorDark.withOpacity(0.9) : ColorTheme.error;

  Color _getErrorBackgroundColor(bool isDark) =>
      isDark
          ? ColorTheme.errorDark.withOpacity(0.15)
          : ColorTheme.error.withOpacity(0.08);

  Color _getErrorBorderColor(bool isDark) =>
      isDark
          ? ColorTheme.errorDark.withOpacity(0.3)
          : ColorTheme.error.withOpacity(0.2);

  EdgeInsets _getContentPadding() =>
      const EdgeInsets.symmetric(horizontal: 18, vertical: 16);
  double _getErrorIconSize() => 18;
  double _getIconSize() => 20;
}

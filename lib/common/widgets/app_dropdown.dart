// lib/common/widgets/app_dropdown.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

class DropdownItem<T> {
  final String label;
  final T value;

  DropdownItem({required this.label, required this.value});
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final List<DropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final Widget? prefix;
  final EdgeInsets? margin;

  const AppDropdown({
    super.key,
    this.label,
    this.placeholder,
    required this.items,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.prefix,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[_buildLabel(), SizedBox(height: 8)],
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  enabled
                      ? ColorTheme.inputBackground
                      : ColorTheme.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    errorText != null
                        ? ColorTheme.error
                        : onChanged != null && value != null
                        ? ColorTheme.inputFocus
                        : ColorTheme.border,
                width:
                    errorText != null || (onChanged != null && value != null)
                        ? 1.5
                        : 1.0,
              ),
              boxShadow: [
                if (enabled && errorText == null)
                  BoxShadow(
                    color: ColorTheme.cardShadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<T>(
                  value: value,
                  icon: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          enabled
                              ? ColorTheme.primaryLight
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color:
                          enabled
                              ? ColorTheme.primary
                              : ColorTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  iconSize: 24,
                  elevation: 8,
                  isDense: false,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(10),
                  hint: Row(
                    children: [
                      if (prefix != null) ...[prefix!, SizedBox(width: 8)],
                      Text(
                        placeholder ?? 'Select an option',
                        style: TextStyle(
                          color: ColorTheme.textTertiary,
                          fontSize: 14,
                          fontFamily: 'JosefinSans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: ColorTheme.textPrimary,
                    fontSize: 14,
                    fontFamily: 'JosefinSans',
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: Colors.white,
                  onChanged: enabled ? onChanged : null,
                  items:
                      items.map<DropdownMenuItem<T>>((DropdownItem<T> item) {
                        return DropdownMenuItem<T>(
                          value: item.value,
                          child: Row(
                            children: [
                              if (prefix != null && item.value == value) ...[
                                prefix!,
                                SizedBox(width: 8),
                              ],
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'JosefinSans',
                                  fontWeight:
                                      item.value == value
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      item.value == value
                                          ? ColorTheme.primary
                                          : ColorTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  menuMaxHeight: 300,
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: ColorTheme.error),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      color: ColorTheme.error,
                      fontSize: 12,
                      fontFamily: 'JosefinSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
            letterSpacing: 0.1,
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorTheme.error,
              fontFamily: 'JosefinSans',
            ),
          ),
      ],
    );
  }
}

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
          if (label != null) ...[_buildLabel(), SizedBox(height: 6)],
          Container(
            decoration: BoxDecoration(
              color:
                  enabled
                      ? Colors.white
                      : ColorTheme.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? ColorTheme.error : ColorTheme.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<T>(
                  value: value,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: ColorTheme.textSecondary,
                  ),
                  iconSize: 24,
                  elevation: 4,
                  isDense: false,
                  isExpanded: true,
                  hint: Text(
                    placeholder ?? 'Select an option',
                    style: TextStyle(
                      color: ColorTheme.textTertiary,
                      fontSize: 14,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  style: TextStyle(
                    color: ColorTheme.textPrimary,
                    fontSize: 14,
                    fontFamily: 'JosefinSans',
                  ),
                  dropdownColor: Colors.white,
                  onChanged: enabled ? onChanged : null,
                  items:
                      items.map<DropdownMenuItem<T>>((DropdownItem<T> item) {
                        return DropdownMenuItem<T>(
                          value: item.value,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        );
                      }).toList(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            SizedBox(height: 4),
            Text(
              errorText!,
              style: TextStyle(
                color: ColorTheme.error,
                fontSize: 12,
                fontFamily: 'JosefinSans',
              ),
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
            fontWeight: FontWeight.w500,
            color: ColorTheme.textPrimary,
            fontFamily: 'JosefinSans',
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorTheme.error,
              fontFamily: 'JosefinSans',
            ),
          ),
      ],
    );
  }
}

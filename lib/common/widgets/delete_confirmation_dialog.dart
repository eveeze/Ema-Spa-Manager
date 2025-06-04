// lib/common/widgets/delete_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String itemName;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final IconData? icon;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.itemName,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final bool isDarkMode = themeController.isDarkMode;
      final Color backgroundColor =
          isDarkMode ? ColorTheme.surfaceDark : Colors.white;
      final Color textPrimaryColor =
          isDarkMode ? ColorTheme.textPrimaryDark : ColorTheme.textPrimary;
      final Color textSecondaryColor =
          isDarkMode ? ColorTheme.textSecondaryDark : ColorTheme.textSecondary;
      final Color errorColor =
          isDarkMode ? ColorTheme.errorDark : ColorTheme.error;

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.delete_outline_rounded,
                  size: 40,
                  color: errorColor,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                  fontFamily: 'JosefinSans',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message with item name highlighted
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondaryColor,
                    fontFamily: 'JosefinSans',
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: message.split("'")[0]),
                    TextSpan(
                      text: "'$itemName'",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                    if (message.split("'").length > 2)
                      TextSpan(text: message.split("'")[2]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            if (onCancel != null) onCancel!();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textSecondaryColor,
                                fontFamily: 'JosefinSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Confirm button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            errorColor,
                            errorColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: errorColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            onConfirm();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  confirmText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'JosefinSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // Static method to show the dialog
  static Future<void> show({
    required String title,
    required String itemName,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    IconData? icon,
  }) {
    return Get.dialog(
      DeleteConfirmationDialog(
        title: title,
        itemName: itemName,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
      ),
      barrierDismissible: false,
    );
  }
}

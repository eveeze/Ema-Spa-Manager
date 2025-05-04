// lib/common/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool fullScreen;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title = 'Oops!',
    required this.message,
    this.onRetry,
    this.fullScreen = false,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final errorContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: ColorTheme.error),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24),
            AppButton(
              text: 'Try Again',
              onPressed: onRetry,
              type: AppButtonType.primary,
              size: AppButtonSize.medium,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: ColorTheme.background,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: errorContent,
        ),
      );
    }

    return Center(child: errorContent);
  }
}

class NetworkErrorWidget extends AppErrorWidget {
  const NetworkErrorWidget({super.key, super.onRetry, super.fullScreen})
    : super(
        title: 'Network Error',
        message: 'Please check your internet connection and try again.',
        icon: Icons.wifi_off_rounded,
      );
}

class ServerErrorWidget extends AppErrorWidget {
  const ServerErrorWidget({super.key, super.onRetry, super.fullScreen})
    : super(
        title: 'Server Error',
        message: 'Something went wrong on our end. Please try again later.',
        icon: Icons.cloud_off_rounded,
      );
}

// lib/common/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool fullScreen;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.buttonLabel,
    this.onButtonPressed,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final emptyStateContent = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: ColorTheme.textTertiary),
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
          if (buttonLabel != null && onButtonPressed != null) ...[
            SizedBox(height: 24),
            AppButton(
              text: buttonLabel!,
              onPressed: onButtonPressed,
              type: AppButtonType.primary,
              size: AppButtonSize.medium,
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
          child: emptyStateContent,
        ),
      );
    }

    return Center(child: emptyStateContent);
  }
}

class NoResultsWidget extends EmptyStateWidget {
  const NoResultsWidget({
    super.key,
    super.message = 'No results found for your search criteria.',
    super.buttonLabel,
    super.onButtonPressed,
    super.fullScreen,
  }) : super(title: 'No Results', icon: Icons.search_off_rounded);
}

class NoItemsWidget extends EmptyStateWidget {
  const NoItemsWidget({
    super.key,
    super.title = 'No Items Yet',
    super.message = 'Start by adding a new item.',
    super.buttonLabel,
    super.onButtonPressed,
    super.fullScreen,
  }) : super(icon: Icons.add_box_outlined);
}

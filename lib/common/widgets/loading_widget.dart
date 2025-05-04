// lib/common/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

enum LoadingSize { small, medium, large }

class LoadingWidget extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? message;
  final bool fullScreen;

  const LoadingWidget({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            strokeWidth: _getStrokeWidth(),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? ColorTheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Container(
        color: Colors.white.withValues(alpha: 0.9),
        alignment: Alignment.center,
        child: loadingWidget,
      );
    }

    return Center(child: loadingWidget);
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingWidget(fullScreen: true, message: loadingMessage),
          ),
      ],
    );
  }
}

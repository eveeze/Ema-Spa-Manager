import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color revenue;
  final Color success;
  final Color warning;
  final Color info;
  final Color danger;

  const AppSemanticColors({
    required this.revenue,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
  });

  @override
  AppSemanticColors copyWith({
    Color? revenue,
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
  }) {
    return AppSemanticColors(
      revenue: revenue ?? this.revenue,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      revenue: Color.lerp(revenue, other.revenue, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

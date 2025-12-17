// lib/common/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final infoTint = (semantic?.info ?? cs.primary);
    final outline = cs.outlineVariant.withValues(alpha: 0.65);

    Widget content({required bool compact}) {
      final iconSize = compact ? 36.0 : 42.0;
      final badgeSize = compact ? 76.0 : 88.0;

      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.all(compact ? spacing.md : spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge (theme-driven)
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: outline),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: compact ? spacing.md : spacing.lg),

              // Title
              Text(
                title,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.xs),

              // Message
              Text(
                message,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.95),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),

              if (buttonLabel != null && onButtonPressed != null) ...[
                SizedBox(height: compact ? spacing.md : spacing.lg),

                // CTA container (still theme-driven)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: outline),
                    boxShadow: AppShadows.soft(cs.shadow),
                  ),
                  padding: EdgeInsets.all(compact ? spacing.sm : spacing.md),
                  child: AppButton(
                    text: buttonLabel!,
                    onPressed: onButtonPressed,
                    type: AppButtonType.primary,
                    size: AppButtonSize.medium,
                  ),
                ),
              ] else ...[
                SizedBox(height: compact ? spacing.sm : spacing.md),
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: infoTint.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // ✅ Key fix:
    // - even when fullScreen == false (often inside a SizedBox), we allow scroll
    // - keep it centered using minHeight = constraints.maxHeight
    Widget buildScrollableCentered({required bool isFullScreen}) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isTight = constraints.maxHeight < 340;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: isFullScreen ? spacing.xl : spacing.md,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: content(compact: isTight)),
            ),
          );
        },
      );
    }

    if (fullScreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: cs.surface,
        alignment: Alignment.center,
        child: buildScrollableCentered(isFullScreen: true),
      );
    }

    return buildScrollableCentered(isFullScreen: false);
  }
}

class NoResultsWidget extends EmptyStateWidget {
  const NoResultsWidget({
    super.key,
    super.message = 'Tidak ada hasil yang cocok dengan filter/pencarian kamu.',
    super.buttonLabel,
    super.onButtonPressed,
    super.fullScreen,
  }) : super(title: 'Tidak Ada Hasil', icon: Icons.search_off_rounded);
}

class NoItemsWidget extends EmptyStateWidget {
  const NoItemsWidget({
    super.key,
    super.title = 'Belum Ada Data',
    super.message =
        'Mulai dengan menambahkan data baru agar halaman ini terisi.',
    super.buttonLabel,
    super.onButtonPressed,
    super.fullScreen,
  }) : super(icon: Icons.add_box_outlined);
}

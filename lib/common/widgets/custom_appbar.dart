import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final double elevation;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.elevation = 0,
    this.showBackButton = true,
    this.bottom,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Get.find<ThemeController>().isDarkMode;

    final Color effectiveForegroundColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimaryContainer;

    return AppBar(
      title: _buildAnimatedTitle(context, effectiveForegroundColor),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      surfaceTintColor: colorScheme.surface,
      elevation: elevation,
      scrolledUnderElevation: 4.0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: actions,
      bottom: bottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
    );
  }

  Widget _buildAnimatedTitle(BuildContext context, Color color) {
    final textColor =
        Get.find<ThemeController>().isDarkMode
            ? color
            : Theme.of(context).colorScheme.onSurface;

    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: 'JosefinSans',
    );

    return Hero(
      tag: 'appbar_title_$title',
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: textStyle ?? const TextStyle(),
        child: Text(title),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color iconColor) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    final effectiveIconColor =
        Get.find<ThemeController>().isDarkMode
            ? iconColor
            : Theme.of(context).colorScheme.onSurface;

    if (Navigator.of(context).canPop() && automaticallyImplyLeading) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: effectiveIconColor),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }
    return null;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class SearchAppBar extends CustomAppBar {
  SearchAppBar({
    super.key,
    required TextEditingController searchController,
    required Function(String) onSearch,
    VoidCallback? onClear,
    String hintText = 'Search...',
    super.title = '',
    super.actions,
    super.onBackPressed,
    super.showBackButton = true,
  }) : super(
         bottom: PreferredSize(
           preferredSize: const Size.fromHeight(64),
           child: _SearchField(
             controller: searchController,
             onSearch: onSearch,
             onClear: onClear,
             hintText: hintText,
           ),
         ),
       );
}

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String hintText;

  const _SearchField({
    required this.controller,
    required this.onSearch,
    this.onClear,
    required this.hintText,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.removeListener(() => setState(() {}));
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasText = widget.controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: theme.inputDecorationTheme.fillColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color:
                _focusNode.hasFocus
                    ? colorScheme.primary
                    : theme
                            .inputDecorationTheme
                            .enabledBorder
                            ?.borderSide
                            .color ??
                        Colors.transparent,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onSearch,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge,
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: Icon(
              Icons.search,
              color:
                  _focusNode.hasFocus
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
            ),
            suffixIcon:
                hasText
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      color: colorScheme.onSurfaceVariant,
                      onPressed: () {
                        widget.controller.clear();
                        if (widget.onClear != null) {
                          widget.onClear!();
                        } else {
                          widget.onSearch('');
                        }
                        _focusNode.requestFocus();
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}

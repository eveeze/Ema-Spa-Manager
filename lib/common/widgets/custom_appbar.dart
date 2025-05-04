// lib/common/widgets/custom_appbar.dart
import 'package:flutter/material.dart';
import 'package:emababyspa/common/theme/color_theme.dart';

enum AppBarType { primary, transparent }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final AppBarType type;
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
    this.type = AppBarType.primary,
    this.elevation = 0,
    this.showBackButton = true,
    this.bottom,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _getTitleColor(),
          fontFamily: 'JosefinSans',
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? _getBackgroundColor(),
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context),
      actions: actions,
      iconTheme: IconThemeData(color: _getIconColor()),
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    if (Navigator.of(context).canPop() && automaticallyImplyLeading) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppBarType.primary:
        return ColorTheme.primary;
      case AppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getTitleColor() {
    switch (type) {
      case AppBarType.primary:
        return Colors.white;
      case AppBarType.transparent:
        return ColorTheme.textPrimary;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AppBarType.primary:
        return Colors.white;
      case AppBarType.transparent:
        return ColorTheme.textPrimary;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null
        ? kToolbarHeight + bottom!.preferredSize.height
        : kToolbarHeight,
  );
}

class SearchAppBar extends CustomAppBar {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String hintText;

  SearchAppBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    this.onClear,
    this.hintText = 'Search...',
    super.title = '',
    super.actions,
    super.onBackPressed,
    super.showBackButton,
  }) : super(
         bottom: PreferredSize(
           preferredSize: Size.fromHeight(56),
           child: _buildSearchField(
             searchController,
             onSearch,
             onClear,
             hintText,
           ),
         ),
       );

  static Widget _buildSearchField(
    TextEditingController controller,
    Function(String) onSearch,
    VoidCallback? onClear,
    String hintText,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ColorTheme.textTertiary,
            fontFamily: 'JosefinSans',
          ),
          prefixIcon: Icon(Icons.search, color: ColorTheme.textSecondary),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: ColorTheme.textSecondary),
                    onPressed: () {
                      controller.clear();
                      if (onClear != null) {
                        onClear();
                      } else {
                        onSearch('');
                      }
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: ColorTheme.textPrimary,
          fontFamily: 'JosefinSans',
        ),
      ),
    );
  }
}

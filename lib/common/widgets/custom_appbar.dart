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
      title: _buildAnimatedTitle(),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? _getBackgroundColor(),
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context),
      actions: _wrapActionsWithFeedback(actions),
      iconTheme: IconThemeData(color: _getIconColor()),
      bottom: bottom,
      shape:
          type == AppBarType.primary
              ? null
              : RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
      flexibleSpace:
          type == AppBarType.primary
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTheme.primary,
                      ColorTheme.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              )
              : null,
    );
  }

  Widget _buildAnimatedTitle() {
    return Hero(
      tag: 'appbar_title_$title',
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return DefaultTextStyle(
          style: TextStyle(),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Opacity(
                opacity: animation.value,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTitleColor(),
                    fontFamily: 'JosefinSans',
                  ),
                ),
              );
            },
          ),
        );
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _getTitleColor(),
          fontFamily: 'JosefinSans',
          letterSpacing: 0.5,
          shadows:
              type == AppBarType.primary
                  ? [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
      ),
    );
  }

  List<Widget>? _wrapActionsWithFeedback(List<Widget>? actionWidgets) {
    if (actionWidgets == null) return null;

    return actionWidgets.map((widget) {
      if (widget is IconButton) {
        return _wrapWithFeedback(widget);
      }
      return widget;
    }).toList();
  }

  Widget _wrapWithFeedback(Widget widget) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: CircleBorder(),
        splashColor: _getSplashColor(),
        highlightColor: _getHighlightColor(),
        child: widget,
      ),
    );
  }

  Color _getSplashColor() {
    switch (type) {
      case AppBarType.primary:
        return Colors.white.withValues(alpha: 0.3);
      case AppBarType.transparent:
        return ColorTheme.primary.withValues(alpha: 0.1);
    }
  }

  Color _getHighlightColor() {
    switch (type) {
      case AppBarType.primary:
        return Colors.white.withValues(alpha: 0.1);
      case AppBarType.transparent:
        return ColorTheme.primary.withValues(alpha: 0.05);
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    if (Navigator.of(context).canPop() && automaticallyImplyLeading) {
      return _wrapWithFeedback(
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            shadows:
                type == AppBarType.primary
                    ? [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isFocused
                          ? ColorTheme.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                  width: 1.5,
                ),
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
                  prefixIcon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.search,
                      color:
                          isFocused
                              ? ColorTheme.primary
                              : ColorTheme.textSecondary,
                      key: ValueKey(isFocused),
                    ),
                  ),
                  suffixIcon:
                      controller.text.isNotEmpty
                          ? TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: ColorTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      controller.clear();
                                      if (onClear != null) {
                                        onClear();
                                      } else {
                                        onSearch('');
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
                cursorColor: ColorTheme.primary,
                cursorWidth: 1.5,
                cursorRadius: Radius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}

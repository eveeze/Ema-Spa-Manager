// lib/common/widgets/custom_appbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

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
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return AppBar(
          title: _buildAnimatedTitle(themeController),
          centerTitle: centerTitle,
          backgroundColor:
              backgroundColor ?? _getBackgroundColor(themeController),
          elevation: elevation,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: _buildLeading(context, themeController),
          actions: _wrapActionsWithFeedback(actions, themeController),
          iconTheme: IconThemeData(color: _getIconColor(themeController)),
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
                      gradient: _getGradient(themeController),
                      boxShadow: [
                        BoxShadow(
                          color: _getShadowColor(themeController),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildAnimatedTitle(ThemeController themeController) {
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
                    color: _getTitleColor(themeController),
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
          color: _getTitleColor(themeController),
          fontFamily: 'JosefinSans',
          letterSpacing: 0.5,
          shadows: _getTitleShadows(themeController),
        ),
      ),
    );
  }

  List<Widget>? _wrapActionsWithFeedback(
    List<Widget>? actionWidgets,
    ThemeController themeController,
  ) {
    if (actionWidgets == null) return null;

    return actionWidgets.map((widget) {
      if (widget is IconButton) {
        return _wrapWithFeedback(widget, themeController);
      }
      return widget;
    }).toList();
  }

  Widget _wrapWithFeedback(Widget widget, ThemeController themeController) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: CircleBorder(),
        splashColor: _getSplashColor(themeController),
        highlightColor: _getHighlightColor(themeController),
        child: widget,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeController themeController) {
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
            shadows: _getIconShadows(themeController),
          ),
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        themeController,
      );
    }

    return null;
  }

  // Theme-aware color and style methods
  Color _getBackgroundColor(ThemeController themeController) {
    switch (type) {
      case AppBarType.primary:
        return themeController.isDarkMode
            ? ColorTheme.surfaceDark
            : ColorTheme.primary;
      case AppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getTitleColor(ThemeController themeController) {
    switch (type) {
      case AppBarType.primary:
        return themeController.isDarkMode
            ? ColorTheme.textPrimaryDark
            : Colors.white;
      case AppBarType.transparent:
        return themeController.isDarkMode
            ? ColorTheme.textPrimaryDark
            : ColorTheme.textPrimary;
    }
  }

  Color _getIconColor(ThemeController themeController) {
    switch (type) {
      case AppBarType.primary:
        return themeController.isDarkMode
            ? ColorTheme.textPrimaryDark
            : Colors.white;
      case AppBarType.transparent:
        return themeController.isDarkMode
            ? ColorTheme.textPrimaryDark
            : ColorTheme.textPrimary;
    }
  }

  Color _getSplashColor(ThemeController themeController) {
    switch (type) {
      case AppBarType.primary:
        return themeController.isDarkMode
            ? ColorTheme.primaryLightDark.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.3);
      case AppBarType.transparent:
        return themeController.isDarkMode
            ? ColorTheme.primaryLightDark.withValues(alpha: 0.1)
            : ColorTheme.primary.withValues(alpha: 0.1);
    }
  }

  Color _getHighlightColor(ThemeController themeController) {
    switch (type) {
      case AppBarType.primary:
        return themeController.isDarkMode
            ? ColorTheme.primaryLightDark.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.1);
      case AppBarType.transparent:
        return themeController.isDarkMode
            ? ColorTheme.primaryLightDark.withValues(alpha: 0.05)
            : ColorTheme.primary.withValues(alpha: 0.05);
    }
  }

  LinearGradient _getGradient(ThemeController themeController) {
    if (themeController.isDarkMode) {
      return LinearGradient(
        colors: [ColorTheme.surfaceDark, ColorTheme.backgroundDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return LinearGradient(
        colors: [
          ColorTheme.primary,
          ColorTheme.primary.withValues(alpha: 0.85),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  Color _getShadowColor(ThemeController themeController) {
    return themeController.isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  List<Shadow>? _getTitleShadows(ThemeController themeController) {
    if (type == AppBarType.primary && !themeController.isDarkMode) {
      return [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withValues(alpha: 0.3),
          offset: Offset(0, 1),
        ),
      ];
    }
    return null;
  }

  List<Shadow>? _getIconShadows(ThemeController themeController) {
    if (type == AppBarType.primary && !themeController.isDarkMode) {
      return [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withValues(alpha: 0.3),
          offset: Offset(0, 1),
        ),
      ];
    }
    return null;
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
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.surfaceDark
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color:
                    themeController.isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
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
                              ? (themeController.isDarkMode
                                  ? ColorTheme.primaryLightDark.withValues(
                                    alpha: 0.5,
                                  )
                                  : ColorTheme.primary.withValues(alpha: 0.5))
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
                        color:
                            themeController.isDarkMode
                                ? ColorTheme.textTertiaryDark
                                : ColorTheme.textTertiary,
                        fontFamily: 'JosefinSans',
                      ),
                      prefixIcon: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.search,
                          color:
                              isFocused
                                  ? (themeController.isDarkMode
                                      ? ColorTheme.primaryLightDark
                                      : ColorTheme.primary)
                                  : (themeController.isDarkMode
                                      ? ColorTheme.textSecondaryDark
                                      : ColorTheme.textSecondary),
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
                                          color:
                                              themeController.isDarkMode
                                                  ? ColorTheme.textSecondaryDark
                                                  : ColorTheme.textSecondary,
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
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textPrimaryDark
                              : ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                    cursorColor:
                        themeController.isDarkMode
                            ? ColorTheme.primaryLightDark
                            : ColorTheme.primary,
                    cursorWidth: 1.5,
                    cursorRadius: Radius.circular(4),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

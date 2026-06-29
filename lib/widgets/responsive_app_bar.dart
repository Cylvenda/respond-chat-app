import 'package:flutter/material.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onLogoTap;
  final VoidCallback? onLogoLongPress;
  final List<Widget>? actions;
  final Widget? drawer;
  final bool showLogo;
  final double elevation;

  const ResponsiveAppBar({
    super.key,
    this.title,
    this.onLogoTap,
    this.onLogoLongPress,
    this.actions,
    this.drawer,
    this.showLogo = true,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final logoSize = isMobile ? 28.0 : 32.0;
    final titleFontSize = isMobile ? 14.0 : 16.0;
    final spacing = isMobile ? 8.0 : 12.0;

    Widget titleWidget = showLogo
        ? GestureDetector(
            onTap: onLogoTap,
            onLongPress: onLogoLongPress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: logoSize,
                  width: logoSize,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.security,
                    color: Colors.white,
                    size: logoSize - 2,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    title ?? 'CyberGuard',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : Text(
            title ?? 'CyberGuard',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    return AppBar(
      title: titleWidget,
      elevation: elevation,
      actions: actions,
      actionsIconTheme: isMobile
          ? const IconThemeData(size: 24)
          : const IconThemeData(size: 28),
    );
  }
}

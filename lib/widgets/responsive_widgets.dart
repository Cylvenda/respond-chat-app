import 'package:flutter/material.dart';

/// A utility class for responsive text sizing and overflow handling.
/// Automatically adjusts text size based on screen width and provides
/// consistent overflow handling with ellipsis.
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final bool autoSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.autoSize = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine device type
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    TextStyle baseStyle = style ?? const TextStyle();

    // Apply responsive font scaling if autoSize is enabled
    if (autoSize && baseStyle.fontSize != null) {
      late double scaleFactor;
      if (isMobile) {
        scaleFactor = 0.85; // 85% of original size on mobile
      } else if (isTablet) {
        scaleFactor = 0.95; // 95% of original size on tablet
      } else {
        scaleFactor = 1.0; // Full size on desktop
      }

      baseStyle = baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
      );
    }

    return Text(
      text,
      style: baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive column layout that stacks widgets vertically on mobile
/// and horizontally on larger screens.
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double breakpoint; // Width at which to switch from column to row

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.all(0),
    this.spacing = 16,
    this.breakpoint = 600,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= breakpoint;

    final childrenWithSpacing = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      childrenWithSpacing.add(children[i]);
      if (i < children.length - 1) {
        childrenWithSpacing.add(
          SizedBox(
            width: isWideScreen ? spacing : 0,
            height: isWideScreen ? 0 : spacing / 2,
          ),
        );
      }
    }

    return Padding(
      padding: padding,
      child: isWideScreen
          ? Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: childrenWithSpacing,
            )
          : Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: childrenWithSpacing,
            ),
    );
  }
}

/// Responsive container that constrains content to a maximum width
/// with automatic padding adjustment for smaller screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double horizontalPaddingMobile;
  final double horizontalPaddingTablet;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(0),
    this.horizontalPaddingMobile = 16,
    this.horizontalPaddingTablet = 24,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final effectivePadding = isMobile
        ? EdgeInsets.symmetric(horizontal: horizontalPaddingMobile)
        : EdgeInsets.symmetric(horizontal: horizontalPaddingTablet);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: effectivePadding, child: child),
      ),
    );
  }
}

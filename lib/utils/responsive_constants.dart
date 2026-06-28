/// Responsive design constants and utilities for the CyberGuard app.
/// 
/// This file contains breakpoints and helper methods for creating
/// responsive layouts that work on all device sizes.
/// 
/// Device Classifications:
/// - Mobile: < 600px (phones)
/// - Tablet: 600px - 900px
/// - Desktop: > 900px
/// 
/// Usage:
/// ```dart
/// final isMobile = screenWidth < ResponsiveConstants.mobileBreakpoint;
/// final isTablet = screenWidth >= ResponsiveConstants.mobileBreakpoint &&
///                 screenWidth < ResponsiveConstants.tabletBreakpoint;
/// ```

class ResponsiveConstants {
  /// Breakpoint for transitioning from mobile to tablet layout (600px)
  static const double mobileBreakpoint = 600;
  
  /// Breakpoint for transitioning from tablet to desktop layout (900px)
  static const double tabletBreakpoint = 900;

  /// Standard horizontal padding for mobile screens
  static const double mobileHorizontalPadding = 16.0;

  /// Standard horizontal padding for tablet screens
  static const double tabletHorizontalPadding = 24.0;

  /// Standard horizontal padding for desktop screens
  static const double desktopHorizontalPadding = 32.0;

  /// Maximum content width for large screens
  static const double maxContentWidth = 1200;

  /// Standard icon size for mobile AppBar
  static const double mobileIconSize = 24.0;

  /// Standard icon size for tablet/desktop AppBar
  static const double tabletIconSize = 28.0;

  /// Font size for mobile titles in AppBar
  static const double mobileTitleFontSize = 14.0;

  /// Font size for tablet/desktop titles in AppBar
  static const double tabletTitleFontSize = 16.0;

  /// Logo size for mobile screens
  static const double mobileLogoSize = 28.0;

  /// Logo size for tablet/desktop screens
  static const double tabletLogoSize = 32.0;
}

/// Helper class for responsive design operations
class ResponsiveHelper {
  /// Determines if the current screen is a mobile device
  static bool isMobile(double screenWidth) {
    return screenWidth < ResponsiveConstants.mobileBreakpoint;
  }

  /// Determines if the current screen is a tablet device
  static bool isTablet(double screenWidth) {
    return screenWidth >= ResponsiveConstants.mobileBreakpoint &&
        screenWidth < ResponsiveConstants.tabletBreakpoint;
  }

  /// Determines if the current screen is a desktop/large screen
  static bool isDesktop(double screenWidth) {
    return screenWidth >= ResponsiveConstants.tabletBreakpoint;
  }

  /// Returns appropriate horizontal padding based on screen width
  static double getHorizontalPadding(double screenWidth) {
    if (isMobile(screenWidth)) {
      return ResponsiveConstants.mobileHorizontalPadding;
    } else if (isTablet(screenWidth)) {
      return ResponsiveConstants.tabletHorizontalPadding;
    } else {
      return ResponsiveConstants.desktopHorizontalPadding;
    }
  }

  /// Returns appropriate icon size based on screen width
  static double getIconSize(double screenWidth) {
    if (isMobile(screenWidth)) {
      return ResponsiveConstants.mobileIconSize;
    } else {
      return ResponsiveConstants.tabletIconSize;
    }
  }

  /// Returns appropriate title font size based on screen width
  static double getTitleFontSize(double screenWidth) {
    if (isMobile(screenWidth)) {
      return ResponsiveConstants.mobileTitleFontSize;
    } else {
      return ResponsiveConstants.tabletTitleFontSize;
    }
  }

  /// Returns appropriate logo size based on screen width
  static double getLogoSize(double screenWidth) {
    if (isMobile(screenWidth)) {
      return ResponsiveConstants.mobileLogoSize;
    } else {
      return ResponsiveConstants.tabletLogoSize;
    }
  }
}

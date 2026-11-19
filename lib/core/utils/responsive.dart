import 'package:flutter/widgets.dart';

enum ScreenSize { compact, medium, expanded }

/// Width breakpoints shared by the whole app.
class Responsive {
  Responsive._();

  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 1024;

  static ScreenSize fromWidth(double width) {
    if (width < mediumBreakpoint) return ScreenSize.compact;
    if (width < expandedBreakpoint) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSize.compact;
}

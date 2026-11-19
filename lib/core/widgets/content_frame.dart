import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/responsive.dart';

/// Centers page content and caps its width on large screens.
class ContentFrame extends StatelessWidget {
  const ContentFrame({required this.child, super.key, this.maxWidth = 1100});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.isCompact(context)
        ? AppSpacing.md
        : AppSpacing.lg;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.lg,
            horizontal,
            0,
          ),
          child: child,
        ),
      ),
    );
  }
}

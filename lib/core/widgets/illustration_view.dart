import 'package:flutter/material.dart';
import 'package:hr_management/core/utils/responsive.dart';
import 'package:hr_management/core/widgets/app_assets.dart';

/// Shows an [AppIllustration] whole (never cropped, never stretched) at a
/// responsive width. Height always follows the image's own aspect ratio.
///
/// Deliberately built without LayoutBuilder so it is safe inside widgets that
/// query intrinsic sizes (e.g. SliverFillRemaining).
class IllustrationView extends StatelessWidget {
  const IllustrationView(
    this.illustration, {
    super.key,
    this.maxWidth,
    this.maxHeight,
  });

  final AppIllustration illustration;

  /// Optional hard cap, e.g. when shown inside a dialog.
  final double? maxWidth;

  /// Optional height cap for short viewports; the width shrinks to match,
  /// so the aspect ratio is still respected.
  final double? maxHeight;

  static double targetWidth(BuildContext context) {
    switch (Responsive.of(context)) {
      case ScreenSize.compact:
        final w = MediaQuery.sizeOf(context).width;
        return (w * 0.72).clamp(210.0, 300.0);
      case ScreenSize.medium:
        return 320;
      case ScreenSize.expanded:
        return 400;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = targetWidth(context);
    if (maxWidth != null && width > maxWidth!) width = maxWidth!;
    if (maxHeight != null) {
      final byHeight = maxHeight! * illustration.aspectRatio;
      if (width > byHeight) width = byHeight < 150 ? 150 : byHeight;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: AspectRatio(
        aspectRatio: illustration.aspectRatio,
        child: Image.asset(
          illustration.path,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

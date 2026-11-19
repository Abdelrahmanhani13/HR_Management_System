import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/theme/app_spacing.dart';

/// A rounded surface with a decorative background asset on its trailing side.
///
/// A gradient layer keeps the text side clean, so content stays readable over
/// every background. The gradient is painted BEHIND the [child] (never above
/// it), otherwise it would wash the text out. Use [dark] for the dark hero
/// artwork (text must then be light); otherwise the panel fades into the
/// white surface.
class BrandPanel extends StatelessWidget {
  const BrandPanel({
    required this.image,
    required this.child,
    super.key,
    this.dark = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.imageAlignment = AlignmentDirectional.centerEnd,
    this.fadeStrength = 1,
    this.bordered = true,
  });

  final String image;
  final Widget child;
  final bool dark;
  final EdgeInsetsGeometry padding;
  final double radius;
  final AlignmentGeometry imageAlignment;

  /// 0 = artwork fully visible, 1 = default fade for readability.
  final double fadeStrength;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final base = dark ? AppColors.navy : AppColors.surface;
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: base,
        borderRadius: borderRadius,
        border: bordered && !dark ? Border.all(color: AppColors.border) : null,
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          alignment: imageAlignment,
          filterQuality: FilterQuality.high,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: dark ? 0.18 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // The readability gradient sits in its own layer *under* the content.
      // (It used to be a `foregroundDecoration`, which paints over the child
      // and tinted the text with the background colour.)
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: dark
                ? [
                    AppColors.navy.withValues(alpha: 0.95 * fadeStrength),
                    AppColors.navy.withValues(alpha: 0.78 * fadeStrength),
                    AppColors.navy.withValues(alpha: 0.25),
                  ]
                : [
                    base.withValues(alpha: 0.97 * fadeStrength),
                    base.withValues(alpha: 0.82 * fadeStrength),
                    base.withValues(alpha: 0.0),
                  ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

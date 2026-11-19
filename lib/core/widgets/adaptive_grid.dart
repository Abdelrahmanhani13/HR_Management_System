import 'package:flutter/widgets.dart';

/// Lays children out in as many equal-width columns as fit [minItemWidth].
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.children,
    super.key,
    this.minItemWidth = 260,
    this.spacing = 20,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        var columns = ((available + spacing) / (minItemWidth + spacing)).floor();
        if (columns < 1) columns = 1;
        final itemWidth = (available - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

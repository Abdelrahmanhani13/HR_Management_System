import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/app_card.dart';

/// Shared frame for the login, forgot-password, and reset-password screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            top: -180,
            end: -120,
            child: _AmbientGlow(color: scheme.primary),
          ),
          PositionedDirectional(
            bottom: -180,
            start: -120,
            child: _AmbientGlow(color: scheme.tertiary),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    constraints.maxWidth >= 960 && constraints.maxHeight >= 640;
                final horizontalPadding = constraints.maxWidth < 360
                    ? AppSpacing.sm + 4
                    : AppSpacing.lg;

                final content = wide
                    ? Row(
                        children: [
                          const Expanded(child: _BrandBlock(expanded: true)),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: _AuthCard(
                              title: title,
                              subtitle: subtitle,
                              child: child,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _BrandBlock(expanded: false),
                          const SizedBox(height: AppSpacing.xl),
                          _AuthCard(
                            title: title,
                            subtitle: subtitle,
                            child: child,
                          ),
                        ],
                      );

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: wide ? 1120 : 480),
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final markSize = expanded ? 72.0 : 52.0;
    final mark = Container(
      width: markSize,
      height: markSize,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          expanded ? AppRadius.md : AppRadius.sm,
        ),
      ),
      child: Icon(
        Icons.badge_outlined,
        color: scheme.onPrimaryContainer,
        size: expanded ? 36 : 26,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بوابة الموارد البشرية',
          style: (expanded ? textTheme.headlineSmall : textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          expanded
              ? 'مساحة عمل آمنة لإدارة الموظفين والحضور من أي جهاز.'
              : 'مساحة عمل آمنة لفريقك',
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );

    if (expanded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mark,
          const SizedBox(height: AppSpacing.lg),
          copy,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        Flexible(child: copy),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

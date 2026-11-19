import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/app_card.dart';

/// Shared frame for the login, forgot-password, and reset-password screens.
///
/// Wide screens show the brand scene (which already contains the company logo)
/// beside the form; narrow screens show the logo above the form on a soft
/// decorative background.
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
    return Scaffold(
      body: Stack(
        children: [
          // Subtle decorative artwork, faded so it never competes with the form.
          PositionedDirectional(
            top: 0,
            end: 0,
            child: IgnorePointer(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(rect),
                child: Image.asset(
                  AppAssets.sectionDotsArc,
                  width: 560,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    constraints.maxWidth >= 960 && constraints.maxHeight >= 600;
                final horizontalPadding = constraints.maxWidth < 360
                    ? AppSpacing.sm + 4
                    : AppSpacing.lg;

                final card = _AuthCard(
                  title: title,
                  subtitle: subtitle,
                  child: child,
                );

                final content = wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: _BrandScene()),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: card),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _CompactLogo(),
                          const SizedBox(height: AppSpacing.lg),
                          card,
                        ],
                      );

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: wide ? 1160 : 460),
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

class _BrandScene extends StatelessWidget {
  const _BrandScene();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: AppAssets.loginBrandSceneAspect,
        child: Image.asset(
          AppAssets.loginBrandScene,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Pioneers Digital Integration Limited',
        ),
      ),
    );
  }
}

class _CompactLogo extends StatelessWidget {
  const _CompactLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: 230,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Pioneers Digital Integration Limited',
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
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

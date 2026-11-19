import 'package:flutter/material.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/illustration_view.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Inline load-error state. The illustration carries the "something went
/// wrong" message itself, so no title is repeated. A [NotImplementedFailure]
/// keeps its explicit notice because the illustration (connection problem)
/// would be misleading there.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, super.key, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final notConnected = failure is NotImplementedFailure;
    return _InlineIllustrationLayout(
      illustration: AppIllustration.error,
      note: notConnected ? failure.message : null,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
    );
  }
}

/// Inline empty state built from an illustration that already contains its
/// own message. Only an optional action button is added.
class IllustratedEmptyView extends StatelessWidget {
  const IllustratedEmptyView({
    required this.illustration,
    super.key,
    this.action,
  });

  final AppIllustration illustration;
  final Widget? action;

  @override
  Widget build(BuildContext context) =>
      _InlineIllustrationLayout(illustration: illustration, action: action);
}

/// Text/icon empty state, for the few cases that have no matching
/// illustration (payroll with no rows, unknown route).
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: scheme.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.md),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineIllustrationLayout extends StatelessWidget {
  const _InlineIllustrationLayout({
    required this.illustration,
    this.note,
    this.action,
  });

  final AppIllustration illustration;
  final String? note;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // Height cap from the screen (not LayoutBuilder: intrinsic-safe).
    final reserved = (note != null ? 56.0 : 0) + (action != null ? 72.0 : 0);
    final maxHeight =
        MediaQuery.sizeOf(context).height * 0.6 - reserved - AppSpacing.lg * 2;
    return _content(context, maxHeight);
  }

  Widget _content(BuildContext context, double? maxHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IllustrationView(illustration, maxHeight: maxHeight),
            if (note != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                note!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.sm),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

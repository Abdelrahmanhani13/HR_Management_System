import 'package:flutter/material.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/illustration_view.dart';

enum AppFeedbackKind { success, error }

/// Centralised success / failure feedback for important operations.
///
/// SnackBars are intentionally kept only for login and logout; everything
/// else reports its outcome through these dialogs. Call them only from a
/// Cubit state *transition* (`listenWhen`) or after an awaited `Either`, so
/// success is never shown before the backend confirms it.
class AppFeedback {
  AppFeedback._();

  static bool _open = false;

  /// Shows the success illustration. Completes when the dialog is dismissed.
  ///
  /// [title]/[message] are for illustrations *without* an embedded message
  /// (see [AppIllustration.hasEmbeddedMessage]); leave them null otherwise so
  /// the text is not repeated.
  static Future<void> success(
    BuildContext context, {
    AppIllustration illustration = AppIllustration.success,
    String? title,
    String? message,
    String closeLabel = 'حسنًا',
  }) async {
    await _show(
      context,
      AppFeedbackDialog(
        kind: AppFeedbackKind.success,
        illustration: illustration,
        title: illustration.hasEmbeddedMessage ? null : title,
        message: illustration.hasEmbeddedMessage ? null : message,
        closeLabel: closeLabel,
      ),
    );
  }

  /// Shows the failure illustration with Retry (when [onRetry] is given) and
  /// Close. Raw exceptions are never shown; only a concise, user-meaningful
  /// detail is added when the illustration alone would be misleading.
  static Future<void> error(
    BuildContext context, {
    Failure? failure,
    VoidCallback? onRetry,
    String? message,
  }) async {
    final retry = await _show(
      context,
      AppFeedbackDialog(
        kind: AppFeedbackKind.error,
        illustration: AppIllustration.error,
        message: message ?? _detailFor(failure),
        showRetry: onRetry != null,
      ),
    );
    if (retry == true) onRetry?.call();
  }

  /// Network / server / unexpected failures are already described by the
  /// illustration, so no extra text. Others carry a specific, actionable
  /// reason (conflict, permission…) that is worth keeping.
  static String? _detailFor(Failure? failure) {
    if (failure == null) return null;
    if (failure is NetworkFailure ||
        failure is ServerFailure ||
        failure is UnexpectedFailure) {
      return null;
    }
    return failure.message;
  }

  static Future<bool?> _show(BuildContext context, Widget dialog) async {
    if (_open) return null; // prevents stacked duplicates from re-emissions
    _open = true;
    try {
      return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'إغلاق',
        barrierColor: AppColors.navy.withValues(alpha: 0.38),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => dialog,
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
    } finally {
      _open = false;
    }
  }
}

class AppFeedbackDialog extends StatelessWidget {
  const AppFeedbackDialog({
    required this.kind,
    required this.illustration,
    super.key,
    this.title,
    this.message,
    this.showRetry = false,
    this.closeLabel = 'إغلاق',
  });

  final AppFeedbackKind kind;
  final AppIllustration illustration;
  final String? title;
  final String? message;
  final bool showRetry;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isError = kind == AppFeedbackKind.error;
    final accent = isError ? AppColors.danger : AppColors.success;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: IllustrationView(illustration, maxWidth: 320),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (showRetry) ...[
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('إعادة المحاولة'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إغلاق'),
                    ),
                  ] else
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: accent),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(closeLabel),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

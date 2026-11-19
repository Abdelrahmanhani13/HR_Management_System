import 'package:flutter/material.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/status_chip.dart';

/// Compact message box for form-level errors and notices.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    required this.message,
    required this.tone,
    super.key,
    this.icon,
  });

  /// Builds a banner from a [Failure]. "Not connected" is shown as info.
  factory InlineBanner.failure(Failure failure, {Key? key}) {
    final notConnected = failure is NotImplementedFailure;
    return InlineBanner(
      key: key,
      message: failure.message,
      tone: notConnected ? StatusTone.info : StatusTone.danger,
      icon: notConnected ? Icons.cloud_off_outlined : Icons.error_outline,
    );
  }

  final String message;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final background = isDark
        ? Color.alphaBlend(
            tone.foreground(context).withValues(alpha: 0.16),
            scheme.surface,
          )
        : tone.background(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: tone.foreground(context)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tone.foreground(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

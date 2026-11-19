import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/theme/app_spacing.dart';

enum StatusTone { success, warning, danger, info, neutral }

extension StatusToneColors on StatusTone {
  Color foreground(BuildContext context) {
    switch (this) {
      case StatusTone.success:
        return Theme.of(context).brightness == Brightness.light
            ? AppColors.success
            : const Color(0xFF9BCDAA);
      case StatusTone.warning:
        return Theme.of(context).brightness == Brightness.light
            ? AppColors.warning
            : const Color(0xFFE2C18A);
      case StatusTone.danger:
        return Theme.of(context).brightness == Brightness.light
            ? AppColors.danger
            : const Color(0xFFE5A19A);
      case StatusTone.info:
        return Theme.of(context).brightness == Brightness.light
            ? AppColors.info
            : const Color(0xFFA8CBDC);
      case StatusTone.neutral:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Color background(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.alphaBlend(
        foreground(context).withValues(alpha: 0.16),
        Theme.of(context).colorScheme.surface,
      );
    }
    switch (this) {
      case StatusTone.success:
        return AppColors.successBg;
      case StatusTone.warning:
        return AppColors.warningBg;
      case StatusTone.danger:
        return AppColors.dangerBg;
      case StatusTone.info:
        return AppColors.infoBg;
      case StatusTone.neutral:
        return AppColors.neutralBg;
    }
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tone.background(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tone.foreground(context)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tone.foreground(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

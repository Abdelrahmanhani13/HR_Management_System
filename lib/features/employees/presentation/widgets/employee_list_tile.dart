import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/avatar_initials.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';

class EmployeeListTile extends StatelessWidget {
  const EmployeeListTile({
    required this.employee,
    required this.onTap,
    super.key,
  });

  final Employee employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final department = employee.departmentName ?? 'بدون قسم';
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarInitials(name: employee.fullName),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$department · ${employee.phone}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (!employee.isActive)
            const StatusChip(label: 'غير نشط', tone: StatusTone.neutral),
          Icon(
            Icons.chevron_right,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

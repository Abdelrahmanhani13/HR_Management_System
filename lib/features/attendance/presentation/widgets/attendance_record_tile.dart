import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';

/// Arrival + session status chips for one attendance record.
class AttendanceStatusChips extends StatelessWidget {
  const AttendanceStatusChips({required this.record, super.key});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        switch (record.arrivalStatus) {
          ArrivalStatus.onTime => const StatusChip(
            label: 'في الموعد',
            tone: StatusTone.success,
          ),
          ArrivalStatus.late => const StatusChip(
            label: 'متأخر',
            tone: StatusTone.warning,
          ),
          ArrivalStatus.unknown => const SizedBox.shrink(),
        },
        if (record.isCheckedOut)
          const StatusChip(label: 'مكتمل', tone: StatusTone.neutral)
        else
          const StatusChip(
            label: 'جارٍ',
            tone: StatusTone.info,
            icon: Icons.schedule,
          ),
        if (record.isEarlyDeparture)
          const StatusChip(label: 'انصراف مبكر', tone: StatusTone.warning),
      ],
    );
  }
}

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({required this.record, super.key, this.onEdit});

  final AttendanceRecord record;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final out = record.checkOut;
    final worked = record.workedDuration;
    final times =
        '${AppFormat.time(record.checkIn)}  →  '
        '${out == null ? '—' : AppFormat.time(out)}';
    final workedText = worked == null ? '—' : AppFormat.duration(worked);

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.employeeName ?? 'موظف غير معروف',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          AppFormat.date(record.date),
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              children: [
                Expanded(flex: 3, child: identity),
                Expanded(
                  flex: 3,
                  child: Text(times, textDirection: TextDirection.ltr),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    workedText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AttendanceStatusChips(record: record),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'تعديل سجل الحضور',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              const SizedBox(height: AppSpacing.sm),
              Text(times, textDirection: TextDirection.ltr),
              if (worked != null)
                Text(
                  'مدة العمل: $workedText',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              AttendanceStatusChips(record: record),
              if (onEdit != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    tooltip: 'تعديل سجل الحضور',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

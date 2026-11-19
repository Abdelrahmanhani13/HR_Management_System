import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/attendance/presentation/cubit/attendance_list_cubit.dart';

/// Date-range and employee filters for the attendance list.
class AttendanceFilters extends StatelessWidget {
  const AttendanceFilters({super.key});

  Future<void> _pickRange(BuildContext context) async {
    final cubit = context.read<AttendanceListCubit>();
    final query = cubit.state.query;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2008),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(start: query.from, end: query.to),
    );
    if (picked != null && !cubit.isClosed) {
      await cubit.setRange(dateOnly(picked.start), dateOnly(picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttendanceListCubit>();
    return BlocBuilder<AttendanceListCubit, AttendanceListState>(
      buildWhen: (p, c) => p.query != c.query || p.employees != c.employees,
      builder: (context, state) {
        final query = state.query;
        final rangeLabel = query.isSingleDay
            ? AppFormat.date(query.from)
            : '${AppFormat.date(query.from)} – ${AppFormat.date(query.to)}';

        final dateButton = OutlinedButton.icon(
          onPressed: () => _pickRange(context),
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(rangeLabel),
        );

        final employee = DropdownButtonFormField<String?>(
          initialValue: query.employeeId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'الموظف'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('كل الموظفين'),
            ),
            for (final e in state.employees)
              DropdownMenuItem<String?>(
                value: e.id,
                child: Text(e.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: cubit.setEmployee,
        );

        final reset = cubit.hasCustomFilters
            ? TextButton.icon(
                onPressed: cubit.resetFilters,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('اليوم'),
              )
            : null;

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                children: [
                  SizedBox(height: 48, child: dateButton),
                  const SizedBox(width: AppSpacing.sm + 4),
                  SizedBox(width: 280, child: employee),
                  if (reset != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    reset,
                  ],
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48, child: dateButton),
                const SizedBox(height: AppSpacing.sm + 4),
                employee,
                if (reset != null)
                  Align(alignment: Alignment.centerLeft, child: reset),
              ],
            );
          },
        );
      },
    );
  }
}

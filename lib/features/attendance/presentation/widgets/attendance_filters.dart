import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:hr_management/features/attendance/presentation/cubit/attendance_list_cubit.dart';

/// Date-range and employee filters for the attendance list.
class AttendanceFilters extends StatelessWidget {
  const AttendanceFilters({super.key});

  Future<void> _pickDay(BuildContext context) async {
    final cubit = context.read<AttendanceListCubit>();
    final query = cubit.state.query;
    final today = dateOnly(DateTime.now());
    final initial = query.isSingleDay ? query.from : query.to;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2008),
      lastDate: today,
      initialDate: initial.isAfter(today) ? today : initial,
    );
    if (picked != null && !cubit.isClosed) {
      await cubit.setDay(picked);
    }
  }

  Future<void> _pickRange(BuildContext context) async {
    final cubit = context.read<AttendanceListCubit>();
    final query = cubit.state.query;
    final today = dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2008),
      lastDate: today,
      initialDateRange: DateTimeRange(
        start: query.from.isAfter(today) ? today : query.from,
        end: query.to.isAfter(today) ? today : query.to,
      ),
    );
    if (picked != null && !cubit.isClosed) {
      await cubit.setRange(dateOnly(picked.start), dateOnly(picked.end));
    }
  }

  /// "اليوم · 19/11/2026", "أمس · ..." or just the date / range.
  static String _label(AttendanceQuery query) {
    if (!query.isSingleDay) {
      return '${AppFormat.date(query.from)} – ${AppFormat.date(query.to)}';
    }
    final today = dateOnly(DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final date = AppFormat.date(query.from);
    if (query.from == today) return 'اليوم · $date';
    if (query.from == yesterday) return 'أمس · $date';
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceListCubit, AttendanceListState>(
      buildWhen: (p, c) => p.query != c.query || p.employees != c.employees,
      builder: (context, state) {
        final query = state.query;
        final cubit = context.read<AttendanceListCubit>();
        final today = dateOnly(DateTime.now());
        final canGoNext = query.isSingleDay && query.from.isBefore(today);

        // Day navigator: previous day / pick a day / next day.
        final dayNavigator = Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'اليوم السابق',
                onPressed: query.isSingleDay ? () => cubit.shiftDay(-1) : null,
                icon: const Icon(Icons.navigate_before),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _pickDay(context),
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    _label(query),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'اليوم التالي',
                onPressed: canGoNext ? () => cubit.shiftDay(1) : null,
                icon: const Icon(Icons.navigate_next),
              ),
            ],
          ),
        );

        final rangeButton = OutlinedButton.icon(
          onPressed: () => _pickRange(context),
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: const Text('فترة'),
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
                  SizedBox(width: 300, child: dayNavigator),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(height: 48, child: rangeButton),
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
                Row(
                  children: [
                    Expanded(child: dayNavigator),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(height: 48, child: rangeButton),
                  ],
                ),
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

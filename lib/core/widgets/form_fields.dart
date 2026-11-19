import 'package:flutter/material.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';

/// Read-only field that opens a date picker. Integrates with [Form].
class AppDateField extends FormField<DateTime> {
  AppDateField({
    required String label,
    required DateTime firstDate,
    required DateTime lastDate,
    super.key,
    super.initialValue,
    super.validator,
    ValueChanged<DateTime>? onChanged,
  }) : super(
          builder: (FormFieldState<DateTime> state) {
            final context = state.context;
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () async {
                var initial = state.value ?? DateTime.now();
                if (initial.isBefore(firstDate)) initial = firstDate;
                if (initial.isAfter(lastDate)) initial = lastDate;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (picked != null) {
                  state.didChange(picked);
                  onChanged?.call(picked);
                }
              },
              child: InputDecorator(
                isEmpty: state.value == null,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(
                  state.value == null ? '' : AppFormat.date(state.value!),
                ),
              ),
            );
          },
        );
}

/// Read-only field that opens a time picker. Integrates with [Form].
class AppTimeField extends FormField<ClockTime> {
  AppTimeField({
    required String label,
    super.key,
    super.initialValue,
    super.validator,
    ValueChanged<ClockTime>? onChanged,
  }) : super(
          builder: (FormFieldState<ClockTime> state) {
            final context = state.context;
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () async {
                final current = state.value;
                final picked = await showTimePicker(
                  context: context,
                  initialTime: current == null
                      ? TimeOfDay.now()
                      : TimeOfDay(hour: current.hour, minute: current.minute),
                );
                if (picked != null) {
                  final value = ClockTime(picked.hour, picked.minute);
                  state.didChange(value);
                  onChanged?.call(value);
                }
              },
              child: InputDecorator(
                isEmpty: state.value == null,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.schedule, size: 18),
                ),
                child: Text(
                  state.value == null ? '' : AppFormat.time(state.value!),
                ),
              ),
            );
          },
        );
}

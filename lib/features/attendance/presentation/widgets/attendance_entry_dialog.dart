import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/widgets/app_feedback_dialog.dart';
import 'package:hr_management/core/widgets/form_fields.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';

class AttendanceEntryDialog extends StatefulWidget {
  const AttendanceEntryDialog({
    required this.employees,
    required this.onSave,
    super.key,
    this.record,
  });

  final List<EmployeeOption> employees;
  final AttendanceRecord? record;
  final Future<Either<Failure, AttendanceRecord>> Function(
    String? recordId,
    AttendanceDraft draft,
  )
  onSave;

  @override
  State<AttendanceEntryDialog> createState() => _AttendanceEntryDialogState();
}

class _AttendanceEntryDialogState extends State<AttendanceEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _employeeId;
  DateTime? _date;
  ClockTime? _checkIn;
  ClockTime? _checkOut;
  late bool _hasCheckOut;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _employeeId = widget.record?.employeeId;
    _date = widget.record?.date ?? dateOnly(DateTime.now());
    _checkIn = widget.record?.checkIn;
    _checkOut = widget.record?.checkOut;
    _hasCheckOut = widget.record?.checkOut != null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final employeeId = _employeeId;
    final date = _date;
    final checkIn = _checkIn;
    if (employeeId == null || date == null || checkIn == null) return;

    setState(() => _submitting = true);

    final result = await widget.onSave(
      widget.record?.id,
      AttendanceDraft(
        employeeId: employeeId,
        date: dateOnly(date),
        checkIn: checkIn,
        checkOut: _hasCheckOut ? _checkOut : null,
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _submitting = false);
        AppFeedback.error(context, failure: failure, onRetry: _submit);
      },
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final now = dateOnly(DateTime.now());

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  record == null ? 'تسجيل حضور' : 'تعديل سجل الحضور',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                if (widget.employees.isEmpty)
                  const InlineBanner(
                    message: 'لا توجد بيانات موظفين متاحة للاختيار.',
                    tone: StatusTone.warning,
                    icon: Icons.info_outline,
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _employeeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'الموظف',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: [
                      for (final employee in widget.employees)
                        DropdownMenuItem(
                          value: employee.id,
                          child: Text(
                            employee.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _employeeId = value),
                    validator: (value) => value == null ? 'اختر الموظف.' : null,
                  ),
                const SizedBox(height: AppSpacing.sm),
                AppDateField(
                  label: 'تاريخ الحضور',
                  initialValue: _date,
                  firstDate: DateTime(2008),
                  lastDate: now,
                  onChanged: (value) => _date = value,
                  validator: (value) =>
                      value == null ? 'اختر تاريخ الحضور.' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTimeField(
                  label: 'وقت الحضور',
                  initialValue: _checkIn,
                  onChanged: (value) => _checkIn = value,
                  validator: (value) =>
                      value == null ? 'أدخل وقت الحضور.' : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _hasCheckOut,
                  title: const Text('تم تسجيل وقت الانصراف'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) => setState(() {
                    _hasCheckOut = value ?? false;
                    if (!_hasCheckOut) _checkOut = null;
                  }),
                ),
                if (_hasCheckOut)
                  AppTimeField(
                    label: 'وقت الانصراف',
                    initialValue: _checkOut,
                    onChanged: (value) => _checkOut = value,
                    validator: (value) {
                      if (value == null) return 'أدخل وقت الانصراف.';
                      if (_checkIn != null && !value.isAfter(_checkIn!)) {
                        return 'يجب أن يكون الانصراف بعد الحضور.';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    FilledButton(
                      onPressed: _submitting || widget.employees.isEmpty
                          ? null
                          : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('حفظ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

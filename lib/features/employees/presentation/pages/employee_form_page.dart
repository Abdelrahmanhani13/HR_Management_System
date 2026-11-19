import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/router/navigation.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/adaptive_grid.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/app_feedback_dialog.dart';
import 'package:hr_management/core/widgets/form_fields.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/employees/domain/employee_rules.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/gender.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_form_cubit.dart';
import 'package:hr_management/features/employees/presentation/utils/employee_validators.dart';

/// Create (`employeeId == null`) or edit an employee.
class EmployeeFormPage extends StatelessWidget {
  const EmployeeFormPage({super.key, this.employeeId});

  final String? employeeId;

  bool get _isEditing => employeeId != null;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeFormCubit, EmployeeFormState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) async {
        final cubit = context.read<EmployeeFormCubit>();
        if (state.submitStatus == SubmissionStatus.success) {
          // Reached only after the backend confirmed the operation.
          await AppFeedback.success(
            context,
            illustration: AppIllustration.success,
          );
          if (!context.mounted) return;
          context.popOrGo(AppRoutes.employees, true);
        } else if (state.submitStatus == SubmissionStatus.failure) {
          await AppFeedback.error(
            context,
            failure: state.submitFailure,
            onRetry: cubit.retrySubmit,
          );
        }
      },
      builder: (context, state) {
        return ContentFrame(
          maxWidth: 900,
          child: Column(
            children: [
              PageHeader(
                title: _isEditing ? 'تعديل بيانات الموظف' : 'إضافة موظف',
                leading: IconButton(
                  tooltip: 'رجوع',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.popOrGo(AppRoutes.employees),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _body(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, EmployeeFormState state) {
    final cubit = context.read<EmployeeFormCubit>();
    final loadFailure = state.loadFailure;
    switch (state.loadStatus) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return const LoadingView();
      case ViewStatus.failure:
        return ErrorView(
          failure: loadFailure!,
          onRetry: () => cubit.init(employeeId: employeeId),
        );
      case ViewStatus.success:
        return _EmployeeForm(
          initial: state.initial,
          departments: state.departments,
          submitting: state.submitStatus == SubmissionStatus.submitting,
          onSubmit: cubit.submit,
        );
    }
  }
}

class _EmployeeForm extends StatefulWidget {
  const _EmployeeForm({
    required this.departments,
    required this.submitting,
    required this.onSubmit,
    this.initial,
  });

  final Employee? initial;
  final List<Department> departments;
  final bool submitting;
  final ValueChanged<EmployeeDraft> onSubmit;

  @override
  State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullName;
  late final TextEditingController _address;
  late final TextEditingController _nationality;
  late final TextEditingController _phone;
  late final TextEditingController _nationalId;
  late final TextEditingController _salary;

  DateTime? _dateOfBirth;
  DateTime? _contractDate;
  Gender? _gender;
  ClockTime? _checkIn;
  ClockTime? _checkOut;
  String? _departmentId;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _fullName = TextEditingController(text: e?.fullName);
    _address = TextEditingController(text: e?.address);
    _nationality = TextEditingController(text: e?.nationality);
    _phone = TextEditingController(text: e?.phone);
    _nationalId = TextEditingController(text: e?.nationalId);
    _salary = TextEditingController(
      text: e == null ? null : _plainNumber(e.salary),
    );
    _dateOfBirth = e?.dateOfBirth;
    _contractDate = e?.contractDate;
    _gender = e?.gender;
    _checkIn = e?.checkInTime;
    _checkOut = e?.checkOutTime;
    _departmentId = e?.departmentId;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _address.dispose();
    _nationality.dispose();
    _phone.dispose();
    _nationalId.dispose();
    _salary.dispose();
    super.dispose();
  }

  static String _plainNumber(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      EmployeeDraft(
        fullName: _fullName.text,
        address: _address.text,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        nationality: _nationality.text,
        phone: _phone.text,
        nationalId: _nationalId.text,
        contractDate: _contractDate!,
        salary: EmployeeValidators.parseSalary(_salary.text),
        checkInTime: _checkIn!,
        checkOutTime: _checkOut!,
        departmentId: _departmentId,
      ),
    );
  }

  /// Active departments, plus the employee's current one even if inactive.
  List<Department> get _selectableDepartments {
    final currentId = widget.initial?.departmentId;
    return widget.departments
        .where((d) => d.isActive || d.id == currentId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final departments = _selectableDepartments;
    final now = DateTime.now();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (departments.isEmpty) ...[
              const InlineBanner(
                message: 'لا توجد أقسام متاحة. يمكنك حفظ الموظف دون قسم.',
                tone: StatusTone.info,
                icon: Icons.info_outline,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('البيانات الشخصية'),
                  AdaptiveGrid(
                    minItemWidth: 300,
                    children: [
                      TextFormField(
                        controller: _fullName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: EmployeeValidators.fullName,
                      ),
                      DropdownButtonFormField<Gender>(
                        initialValue: _gender,
                        decoration: const InputDecoration(
                          labelText: 'النوع',
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        items: [
                          for (final g in Gender.values)
                            DropdownMenuItem<Gender>(
                              value: g,
                              child: Text(g.label),
                            ),
                        ],
                        onChanged: (value) => setState(() => _gender = value),
                        validator: EmployeeValidators.gender,
                      ),
                      AppDateField(
                        label: 'تاريخ الميلاد',
                        initialValue: _dateOfBirth,
                        firstDate: DateTime(1940),
                        lastDate: now,
                        onChanged: (value) => _dateOfBirth = value,
                        validator: EmployeeValidators.dateOfBirth,
                      ),
                      TextFormField(
                        controller: _nationality,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'الجنسية',
                          prefixIcon: Icon(Icons.public_outlined),
                        ),
                        validator: EmployeeValidators.nationality,
                      ),
                      TextFormField(
                        controller: _phone,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: EmployeeValidators.phone,
                      ),
                      TextFormField(
                        controller: _nationalId,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الرقم القومي',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: EmployeeValidators.nationalId,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _address,
                    minLines: 2,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: EmployeeValidators.address,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('بيانات العمل'),
                  AdaptiveGrid(
                    minItemWidth: 300,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _departmentId ?? '',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'القسم (اختياري)',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('بدون قسم'),
                          ),
                          for (final d in departments)
                            DropdownMenuItem<String>(
                              value: d.id,
                              child: Text(
                                d.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _departmentId = value == null || value.isEmpty
                              ? null
                              : value,
                        ),
                      ),
                      AppDateField(
                        label: 'تاريخ العقد',
                        initialValue: _contractDate,
                        firstDate: EmployeeRules.minContractDate,
                        lastDate: DateTime(now.year + 1, 12, 31),
                        onChanged: (value) => _contractDate = value,
                        validator: EmployeeValidators.contractDate,
                      ),
                      TextFormField(
                        controller: _salary,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'الراتب',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: EmployeeValidators.salary,
                      ),
                      AppTimeField(
                        label: 'بداية الدوام',
                        initialValue: _checkIn,
                        onChanged: (value) => _checkIn = value,
                        validator: (v) =>
                            EmployeeValidators.time(v, 'بداية الدوام'),
                      ),
                      AppTimeField(
                        label: 'نهاية الدوام',
                        initialValue: _checkOut,
                        onChanged: (value) => _checkOut = value,
                        validator: (v) =>
                            EmployeeValidators.time(v, 'نهاية الدوام'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton(
                  onPressed: widget.submitting
                      ? null
                      : () => context.popOrGo(AppRoutes.employees),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: widget.submitting ? null : _save,
                  child: widget.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.initial == null
                              ? 'إضافة الموظف'
                              : 'حفظ التعديلات',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

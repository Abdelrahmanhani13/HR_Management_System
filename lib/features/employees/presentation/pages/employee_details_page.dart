import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/router/navigation.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/avatar_initials.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/feedback.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_details_cubit.dart';

class EmployeeDetailsPage extends StatelessWidget {
  const EmployeeDetailsPage({required this.employeeId, super.key});

  final String employeeId;

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<EmployeeDetailsCubit>();
    final changed = await context.push<bool>(
      AppRoutes.employeeEdit(employeeId),
    );
    if (changed == true && !cubit.isClosed) {
      await cubit.load(employeeId, silent: true);
    }
  }

  Future<void> _deactivate(BuildContext context, Employee employee) async {
    final cubit = context.read<EmployeeDetailsCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'إيقاف الموظف؟',
      message:
          'سيتم تغيير حالة ${employee.fullName} إلى غير نشط. '
          'يمكنك إعادة تفعيله لاحقًا.',
      confirmLabel: 'إيقاف',
      destructive: true,
    );
    if (confirmed) await cubit.setActive(isActive: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeDetailsCubit, EmployeeDetailsState>(
      listenWhen: (p, c) => p.actionStatus != c.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == SubmissionStatus.success) {
          final active = state.employee?.isActive ?? false;
          showAppSnackBar(
            context,
            active ? 'تمت إعادة تفعيل الموظف' : 'تم إيقاف الموظف',
          );
        } else if (state.actionStatus == SubmissionStatus.failure) {
          showAppSnackBar(
            context,
            state.actionFailure?.message ?? 'تعذر تحديث بيانات الموظف.',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final employee = state.employee;
        return ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: employee?.fullName ?? 'الموظف',
                subtitle: employee?.departmentName,
                leading: IconButton(
                  tooltip: 'رجوع',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.popOrGo(AppRoutes.employees),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _body(context, state, employee)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    EmployeeDetailsState state,
    Employee? employee,
  ) {
    final failure = state.failure;
    if (state.status == ViewStatus.failure && failure != null) {
      return ErrorView(
        failure: failure,
        onRetry: () => context.read<EmployeeDetailsCubit>().reload(),
      );
    }
    if (employee == null) return const LoadingView();

    final busy = state.actionStatus == SubmissionStatus.submitting;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(
                label: employee.isActive ? 'نشط' : 'غير نشط',
                tone: employee.isActive ? StatusTone.success : StatusTone.neutral,
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _edit(context),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('تعديل'),
              ),
              if (employee.isActive)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: busy ? null : () => _deactivate(context, employee),
                  icon: const Icon(Icons.person_off_outlined, size: 18),
                  label: const Text('إيقاف'),
                )
              else
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => context
                          .read<EmployeeDetailsCubit>()
                          .setActive(isActive: true),
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text('إعادة التفعيل'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final personal = _PersonalCard(employee: employee);
              final employment = _EmploymentCard(employee: employee);
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: personal),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: employment),
                  ],
                );
              }
              return Column(
                children: [
                  personal,
                  const SizedBox(height: AppSpacing.md),
                  employment,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PersonalCard extends StatelessWidget {
  const _PersonalCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitials(name: employee.fullName, size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  employee.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionTitle('البيانات الشخصية'),
          InfoRow(label: 'النوع', value: employee.gender.label),
          InfoRow(
            label: 'تاريخ الميلاد',
            value: AppFormat.date(employee.dateOfBirth),
          ),
          InfoRow(label: 'الجنسية', value: employee.nationality),
          InfoRow(label: 'الرقم القومي', value: employee.nationalId),
          InfoRow(label: 'الهاتف', value: employee.phone),
          InfoRow(label: 'العنوان', value: employee.address),
        ],
      ),
    );
  }
}

class _EmploymentCard extends StatelessWidget {
  const _EmploymentCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('بيانات العمل'),
          InfoRow(
            label: 'القسم',
            value: employee.departmentName ?? 'غير متاح',
          ),
          InfoRow(
            label: 'تاريخ العقد',
            value: AppFormat.date(employee.contractDate),
          ),
          InfoRow(label: 'الراتب', value: AppFormat.number(employee.salary)),
          InfoRow(
            label: 'ساعات العمل',
            value: '${AppFormat.time(employee.checkInTime)} – '
                '${AppFormat.time(employee.checkOutTime)}',
          ),
          InfoRow(
            label: 'حساب تسجيل الدخول',
            value: employee.hasLinkedAccount ? 'مرتبط' : 'غير مرتبط',
          ),
          InfoRow(
            label: 'تاريخ الإضافة',
            value: AppFormat.dateTime(employee.createdAt),
          ),
          InfoRow(
            label: 'آخر تحديث',
            value: AppFormat.dateTime(employee.updatedAt),
          ),
        ],
      ),
    );
  }
}

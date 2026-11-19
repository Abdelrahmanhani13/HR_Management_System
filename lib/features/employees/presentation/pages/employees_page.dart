import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/responsive.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:hr_management/features/employees/presentation/widgets/employee_filters.dart';
import 'package:hr_management/features/employees/presentation/widgets/employee_list_tile.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  Future<void> _openDetails(BuildContext context, String id) async {
    final cubit = context.read<EmployeesCubit>();
    await context.push<bool>(AppRoutes.employeeDetails(id));
    // The employee may have been edited or deactivated meanwhile.
    if (!cubit.isClosed) await cubit.load(silent: true);
  }

  Future<void> _openCreate(BuildContext context) async {
    final cubit = context.read<EmployeesCubit>();
    final created = await context.push<bool>(AppRoutes.employeeNew);
    if (created == true && !cubit.isClosed) await cubit.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    return ContentFrame(
      child: Column(
        children: [
          BlocBuilder<EmployeesCubit, EmployeesState>(
            buildWhen: (p, c) =>
                p.status != c.status ||
                p.employees.length != c.employees.length,
            builder: (context, state) {
              final count = state.employees.length;
              return PageHeader(
                title: 'الموظفون',
                subtitle: state.status == ViewStatus.success
                    ? '${AppFormat.number(count)} موظف'
                    : null,
                actions: [
                  if (compact)
                    IconButton.filled(
                      tooltip: 'إضافة موظف',
                      onPressed: () => _openCreate(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => _openCreate(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('إضافة موظف'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          const EmployeeFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<EmployeesCubit, EmployeesState>(
              builder: (context, state) => _EmployeesBody(
                state: state,
                onOpen: (id) => _openDetails(context, id),
                onAdd: () => _openCreate(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeesBody extends StatelessWidget {
  const _EmployeesBody({
    required this.state,
    required this.onOpen,
    required this.onAdd,
  });

  final EmployeesState state;
  final ValueChanged<String> onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EmployeesCubit>();
    final failure = state.failure;

    if (state.status == ViewStatus.failure && failure != null) {
      return ErrorView(failure: failure, onRetry: cubit.load);
    }
    if (state.employees.isEmpty) {
      if (state.status == ViewStatus.initial ||
          state.status == ViewStatus.loading) {
        return const LoadingView();
      }
      return state.query.hasFilters
          ? EmptyView(
              icon: Icons.search_off,
              title: 'لا توجد نتائج مطابقة',
              message: 'جرّب البحث بكلمات مختلفة أو امسح عوامل التصفية.',
              action: OutlinedButton(
                onPressed: cubit.clearFilters,
                child: const Text('مسح عوامل التصفية'),
              ),
            )
          : EmptyView(
              icon: Icons.groups_outlined,
              title: 'لا يوجد موظفون بعد',
              message: 'أضف أول موظف لبدء استخدام النظام.',
              action: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('إضافة موظف'),
              ),
            );
    }

    return Column(
      children: [
        if (state.status == ViewStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cubit.load(silent: true),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemCount: state.employees.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final employee = state.employees[index];
                return EmployeeListTile(
                  employee: employee,
                  onTap: () => onOpen(employee.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

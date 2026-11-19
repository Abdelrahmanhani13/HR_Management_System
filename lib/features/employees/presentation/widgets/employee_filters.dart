import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';
import 'package:hr_management/features/employees/presentation/cubit/employees_cubit.dart';

/// Search box + department and status filters for the employees list.
class EmployeeFilters extends StatefulWidget {
  const EmployeeFilters({super.key});

  @override
  State<EmployeeFilters> createState() => _EmployeeFiltersState();
}

class _EmployeeFiltersState extends State<EmployeeFilters> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<EmployeesCubit>().state.query.searchText,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EmployeesCubit>();
    return BlocConsumer<EmployeesCubit, EmployeesState>(
      // Keep the text box in sync when filters are cleared elsewhere.
      listenWhen: (previous, current) =>
          previous.query.searchText != current.query.searchText &&
          current.query.searchText != _searchController.text,
      listener: (context, state) {
        _searchController.text = state.query.searchText;
      },
      buildWhen: (previous, current) =>
          previous.query != current.query ||
          previous.departments != current.departments,
      builder: (context, state) {
        final search = TextField(
          controller: _searchController,
          onChanged: cubit.search,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو الهاتف أو الرقم القومي',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: state.query.searchText.isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح البحث',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      cubit.search('');
                    },
                  ),
          ),
        );

        final department = DropdownButtonFormField<String?>(
          initialValue: state.query.departmentId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'القسم'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('كل الأقسام'),
            ),
            for (final d in state.departments)
              DropdownMenuItem<String?>(
                value: d.id,
                child: Text(d.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: cubit.setDepartment,
        );

        final status = DropdownButtonFormField<EmployeeActiveFilter>(
          initialValue: state.query.activeFilter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'الحالة'),
          items: [
            for (final f in EmployeeActiveFilter.values)
              DropdownMenuItem<EmployeeActiveFilter>(
                value: f,
                child: Text(f.label),
              ),
          ],
          onChanged: (value) {
            if (value != null) cubit.setActiveFilter(value);
          },
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: AppSpacing.sm + 4),
                  SizedBox(width: 220, child: department),
                  const SizedBox(width: AppSpacing.sm + 4),
                  SizedBox(width: 170, child: status),
                ],
              );
            }
            return Column(
              children: [
                search,
                const SizedBox(height: AppSpacing.sm + 4),
                Row(
                  children: [
                    Expanded(child: department),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(child: status),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

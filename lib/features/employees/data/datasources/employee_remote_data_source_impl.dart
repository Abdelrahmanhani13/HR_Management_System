import 'package:hr_management/core/error/supabase_error_mapper.dart';
import 'package:hr_management/features/employees/data/datasources/employee_remote_data_source.dart';
import 'package:hr_management/features/employees/data/models/department_model.dart';
import 'package:hr_management/features/employees/data/models/employee_draft_mapper.dart';
import 'package:hr_management/features/employees/data/models/employee_model.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  const EmployeeRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  /// Matches `EmployeeModel.fromJson`: the department comes back nested under
  /// `departments`.
  static const String _select = '*, departments(name)';

  static const Map<String, String> _uniqueFields = {
    'phone': 'رقم التليفون مسجل لموظف آخر.',
    'national_id': 'الرقم القومي مسجل لموظف آخر.',
  };

  /// Removes characters that have a meaning inside a PostgREST `or(...)`
  /// filter, so user input can never change the structure of the filter.
  static String _sanitize(String raw) =>
      raw.trim().replaceAll(RegExp(r'[,()"\\]'), ' ').trim();

  @override
  Future<List<EmployeeModel>> getEmployees(EmployeeQuery query) {
    return runSupabase(() async {
      var request = _client.from('employees').select(_select);

      final text = _sanitize(query.searchText);
      if (text.isNotEmpty) {
        request = request.or(
          'full_name.ilike.%$text%,phone.ilike.%$text%,national_id.ilike.%$text%',
        );
      }
      if (query.departmentId != null) {
        request = request.eq('department_id', query.departmentId!);
      }
      switch (query.activeFilter) {
        case EmployeeActiveFilter.active:
          request = request.eq('is_active', true);
        case EmployeeActiveFilter.inactive:
          request = request.eq('is_active', false);
        case EmployeeActiveFilter.all:
          break;
      }

      final rows = await request.order('full_name');
      return rows.map(EmployeeModel.fromJson).toList();
    });
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) {
    return runSupabase(
      () async {
        final row = await _client
            .from('employees')
            .select(_select)
            .eq('id', id)
            .single();
        return EmployeeModel.fromJson(row);
      },
      singleRowMessage: 'الموظف غير موجود أو ليس لديك صلاحية عرضه.',
    );
  }

  @override
  Future<List<DepartmentModel>> getDepartments() {
    return runSupabase(() async {
      final rows = await _client.from('departments').select().order('name');
      return rows.map(DepartmentModel.fromJson).toList();
    });
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeDraft draft) {
    return runSupabase(
      () async {
        final row = await _client
            .from('employees')
            .insert(draft.toJson())
            .select(_select)
            .single();
        return EmployeeModel.fromJson(row);
      },
      uniqueFields: _uniqueFields,
    );
  }

  @override
  Future<EmployeeModel> updateEmployee(String id, EmployeeDraft draft) {
    // `updated_at` is maintained by trg_employees_updated_at (handle_updated_at).
    return runSupabase(
      () async {
        final row = await _client
            .from('employees')
            .update(draft.toJson())
            .eq('id', id)
            .select(_select)
            .single();
        return EmployeeModel.fromJson(row);
      },
      uniqueFields: _uniqueFields,
      singleRowMessage: 'الموظف غير موجود أو ليس لديك صلاحية تعديله.',
    );
  }

  @override
  Future<EmployeeModel> setEmployeeActive(String id, {required bool isActive}) {
    // Needs `employees.update` (RLS) AND `employees.delete` (trigger
    // guard_employee_active_change). `deactivated_at` is set by the database.
    return runSupabase(
      () async {
        final row = await _client
            .from('employees')
            .update({'is_active': isActive})
            .eq('id', id)
            .select(_select)
            .single();
        return EmployeeModel.fromJson(row);
      },
      singleRowMessage: 'الموظف غير موجود أو ليس لديك صلاحية تغيير حالته.',
    );
  }
}

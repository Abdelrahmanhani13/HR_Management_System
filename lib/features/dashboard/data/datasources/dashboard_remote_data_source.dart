import 'package:hr_management/core/error/exceptions.dart';
import 'package:hr_management/core/error/supabase_error_mapper.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary(DateTime day);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<DashboardSummaryModel> getSummary(DateTime day) {
    return runSupabase(() async {
      // RLS returns EMPTY lists (not errors) when a permission is missing, so
      // check explicitly; otherwise the dashboard would show misleading zeros.
      final allowed = await Future.wait([
        _has('employees.view'),
        _has('attendance.view'),
      ]);
      if (!allowed[0] || !allowed[1]) {
        throw const PermissionAppException(
          'ليس لديك صلاحية عرض لوحة المتابعة.',
        );
      }

      final results = await Future.wait([
        _client.from('employees').select('is_active'),
        _client
            .from('attendance')
            .select('check_in, check_out, employees(check_in_time)')
            .eq('attendance_date', AppFormat.sqlDate(day)),
      ]);

      final employees = results[0];
      final attendance = results[1];

      final active = employees.where((e) => e['is_active'] == true).length;

      var checkedOut = 0;
      var late = 0;
      for (final row in attendance) {
        if (row['check_out'] != null) checkedOut++;

        final employee = row['employees'];
        final scheduled =
            employee is Map<String, dynamic> ? employee['check_in_time'] : null;
        if (scheduled is String &&
            ClockTime.parse(row['check_in'] as String)
                .isAfter(ClockTime.parse(scheduled))) {
          late++;
        }
      }

      return DashboardSummaryModel(
        totalEmployees: employees.length,
        activeEmployees: active,
        checkedInToday: attendance.length,
        lateToday: late,
        checkedOutToday: checkedOut,
      );
    });
  }

  Future<bool> _has(String code) async {
    final res = await _client.rpc(
      'has_permission',
      params: {'permission_code': code},
    );
    return res == true;
  }
}

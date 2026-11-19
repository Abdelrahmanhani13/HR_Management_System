import 'package:hr_management/core/error/supabase_error_mapper.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:hr_management/features/attendance/data/models/attendance_models.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  const AttendanceRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;
  static const String _recordSelect =
      'id, employee_id, attendance_date, check_in, check_out, '
      'employees(full_name, check_in_time, check_out_time)';

  @override
  Future<List<AttendanceRecordModel>> getRecords(AttendanceQuery query) {
    return runSupabase(() async {
      var request = _client
          .from('attendance')
          .select(_recordSelect)
          .gte('attendance_date', AppFormat.sqlDate(query.from))
          .lte('attendance_date', AppFormat.sqlDate(query.to));

      if (query.employeeId != null) {
        request = request.eq('employee_id', query.employeeId!);
      }

      final rows = await request
          .order('attendance_date', ascending: false)
          .order('check_in', ascending: false);
      return rows.map(AttendanceRecordModel.fromJson).toList();
    });
  }

  @override
  Future<List<EmployeeOptionModel>> getEmployeeOptions() {
    return runSupabase(() async {
      final rows = await _client
          .from('employees')
          .select('id, full_name')
          .order('full_name');
      return rows.map(EmployeeOptionModel.fromJson).toList();
    });
  }

  @override
  Future<AttendanceRecordModel> createRecord(AttendanceDraft draft) {
    return runSupabase(() async {
      final row = await _client
          .from('attendance')
          .insert(draft.toJson())
          .select(_recordSelect)
          .single();
      return AttendanceRecordModel.fromJson(row);
    }, singleRowMessage: 'تعذر حفظ سجل الحضور.');
  }

  @override
  Future<AttendanceRecordModel> updateRecord(String id, AttendanceDraft draft) {
    return runSupabase(() async {
      final row = await _client
          .from('attendance')
          .update(draft.toJson())
          .eq('id', id)
          .select(_recordSelect)
          .single();
      return AttendanceRecordModel.fromJson(row);
    }, singleRowMessage: 'السجل غير موجود أو ليس لديك صلاحية تعديله.');
  }
}

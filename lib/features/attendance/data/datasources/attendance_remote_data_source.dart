import 'package:hr_management/features/attendance/data/models/attendance_models.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';

/// Contract for `attendance` access. Implementations throw `AppException`s.
abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> getRecords(AttendanceQuery query);

  Future<List<EmployeeOptionModel>> getEmployeeOptions();

  Future<AttendanceRecordModel> createRecord(AttendanceDraft draft);

  Future<AttendanceRecordModel> updateRecord(String id, AttendanceDraft draft);
}

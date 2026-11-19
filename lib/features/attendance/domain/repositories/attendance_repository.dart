import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceRecord>>> getRecords(
    AttendanceQuery query,
  );

  Future<Either<Failure, List<EmployeeOption>>> getEmployeeOptions();

  Future<Either<Failure, AttendanceRecord>> createRecord(AttendanceDraft draft);

  Future<Either<Failure, AttendanceRecord>> updateRecord(
    String id,
    AttendanceDraft draft,
  );
}

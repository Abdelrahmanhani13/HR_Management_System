import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';
import 'package:hr_management/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._remote);

  final AttendanceRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getRecords(
    AttendanceQuery query,
  ) => guardCall<List<AttendanceRecord>>(() => _remote.getRecords(query));

  @override
  Future<Either<Failure, List<EmployeeOption>>> getEmployeeOptions() =>
      guardCall<List<EmployeeOption>>(_remote.getEmployeeOptions);

  @override
  Future<Either<Failure, AttendanceRecord>> createRecord(
    AttendanceDraft draft,
  ) => guardCall<AttendanceRecord>(() => _remote.createRecord(draft));

  @override
  Future<Either<Failure, AttendanceRecord>> updateRecord(
    String id,
    AttendanceDraft draft,
  ) => guardCall<AttendanceRecord>(() => _remote.updateRecord(id, draft));
}

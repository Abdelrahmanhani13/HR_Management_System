import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';
import 'package:hr_management/features/attendance/domain/repositories/attendance_repository.dart';

class GetAttendanceRecords
    implements UseCase<List<AttendanceRecord>, AttendanceQuery> {
  const GetAttendanceRecords(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<Either<Failure, List<AttendanceRecord>>> call(
    AttendanceQuery params,
  ) => _repository.getRecords(params);
}

class GetEmployeeOptions implements UseCase<List<EmployeeOption>, NoParams> {
  const GetEmployeeOptions(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<Either<Failure, List<EmployeeOption>>> call(NoParams params) =>
      _repository.getEmployeeOptions();
}

class CreateAttendanceRecord
    implements UseCase<AttendanceRecord, AttendanceDraft> {
  const CreateAttendanceRecord(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<Either<Failure, AttendanceRecord>> call(AttendanceDraft params) =>
      _repository.createRecord(params);
}

class UpdateAttendanceRecord
    implements UseCase<AttendanceRecord, UpdateAttendanceParams> {
  const UpdateAttendanceRecord(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<Either<Failure, AttendanceRecord>> call(
    UpdateAttendanceParams params,
  ) => _repository.updateRecord(params.id, params.draft);
}

class UpdateAttendanceParams extends Equatable {
  const UpdateAttendanceParams({required this.id, required this.draft});

  final String id;
  final AttendanceDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

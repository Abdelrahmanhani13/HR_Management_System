import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_query.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';
import 'package:hr_management/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:fpdart/fpdart.dart';

class AttendanceListState extends Equatable {
  const AttendanceListState({
    required this.query,
    this.status = ViewStatus.initial,
    this.records = const [],
    this.employees = const [],
    this.failure,
  });

  final AttendanceQuery query;
  final ViewStatus status;
  final List<AttendanceRecord> records;
  final List<EmployeeOption> employees;
  final Failure? failure;

  AttendanceListState copyWith({
    AttendanceQuery? query,
    ViewStatus? status,
    List<AttendanceRecord>? records,
    List<EmployeeOption>? employees,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AttendanceListState(
      query: query ?? this.query,
      status: status ?? this.status,
      records: records ?? this.records,
      employees: employees ?? this.employees,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [query, status, records, employees, failure];
}

class AttendanceListCubit extends Cubit<AttendanceListState> {
  AttendanceListCubit({
    required GetAttendanceRecords getRecords,
    required GetEmployeeOptions getEmployeeOptions,
    required CreateAttendanceRecord createRecord,
    required UpdateAttendanceRecord updateRecord,
    DateTime Function()? now,
  }) : _getRecords = getRecords,
       _getEmployeeOptions = getEmployeeOptions,
       _createRecord = createRecord,
       _updateRecord = updateRecord,
       _now = now ?? DateTime.now,
       super(
         AttendanceListState(
           query: AttendanceQuery.today((now ?? DateTime.now)()),
         ),
       );

  final GetAttendanceRecords _getRecords;
  final GetEmployeeOptions _getEmployeeOptions;
  final CreateAttendanceRecord _createRecord;
  final UpdateAttendanceRecord _updateRecord;
  final DateTime Function() _now;

  int _requestId = 0;

  /// True when the filters differ from the default (today, all employees).
  bool get hasCustomFilters => state.query != AttendanceQuery.today(_now());

  Future<void> init() async {
    unawaited(_loadEmployeeOptions());
    await load();
  }

  Future<void> load({bool silent = false}) async {
    final requestId = ++_requestId;
    if (!silent) {
      emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    }
    final result = await _getRecords(state.query);
    // Ignore stale responses (the user changed filters meanwhile).
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ViewStatus.failure, failure: failure)),
      (records) => emit(
        state.copyWith(
          status: ViewStatus.success,
          records: records,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> setRange(DateTime from, DateTime to) {
    emit(
      state.copyWith(
        query: state.query.copyWith(from: from, to: to),
      ),
    );
    return load();
  }

  /// Shows a single calendar day (any past day up to today).
  Future<void> setDay(DateTime day) {
    final d = dateOnly(day);
    return setRange(d, d);
  }

  /// Moves a single-day view by [days] (negative = earlier). Does nothing for
  /// multi-day ranges or when the result would be after today.
  Future<void> shiftDay(int days) async {
    final query = state.query;
    if (!query.isSingleDay) return;
    final from = query.from;
    final target = DateTime(from.year, from.month, from.day + days);
    if (target.isAfter(dateOnly(_now()))) return;
    await setDay(target);
  }

  Future<void> setEmployee(String? employeeId) {
    emit(
      state.copyWith(
        query: employeeId == null
            ? state.query.copyWith(clearEmployee: true)
            : state.query.copyWith(employeeId: employeeId),
      ),
    );
    return load();
  }

  Future<void> resetFilters() {
    emit(state.copyWith(query: AttendanceQuery.today(_now())));
    return load();
  }

  Future<Either<Failure, AttendanceRecord>> saveRecord({
    String? recordId,
    required AttendanceDraft draft,
  }) async {
    final result = recordId == null
        ? await _createRecord(draft)
        : await _updateRecord(
            UpdateAttendanceParams(id: recordId, draft: draft),
          );
    final saved = result.fold((_) => false, (_) => true);
    if (saved && !isClosed) await load(silent: true);
    return result;
  }

  Future<void> _loadEmployeeOptions() async {
    final result = await _getEmployeeOptions(const NoParams());
    if (isClosed) return;
    // A failure here only hides the employee filter options.
    result.fold((_) {}, (employees) {
      emit(state.copyWith(employees: employees));
    });
  }
}

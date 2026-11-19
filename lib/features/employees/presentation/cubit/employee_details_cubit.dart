import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/usecases/employee_usecases.dart';

class EmployeeDetailsState extends Equatable {
  const EmployeeDetailsState({
    this.status = ViewStatus.initial,
    this.employee,
    this.failure,
    this.actionStatus = SubmissionStatus.idle,
    this.actionFailure,
  });

  final ViewStatus status;
  final Employee? employee;
  final Failure? failure;

  /// Status of the activate / deactivate action.
  final SubmissionStatus actionStatus;
  final Failure? actionFailure;

  EmployeeDetailsState copyWith({
    ViewStatus? status,
    Employee? employee,
    Failure? failure,
    bool clearFailure = false,
    SubmissionStatus? actionStatus,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) {
    return EmployeeDetailsState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      failure: clearFailure ? null : (failure ?? this.failure),
      actionStatus: actionStatus ?? this.actionStatus,
      actionFailure:
          clearActionFailure ? null : (actionFailure ?? this.actionFailure),
    );
  }

  @override
  List<Object?> get props =>
      [status, employee, failure, actionStatus, actionFailure];
}

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  EmployeeDetailsCubit({
    required GetEmployeeById getEmployeeById,
    required SetEmployeeActive setEmployeeActive,
  })  : _getEmployeeById = getEmployeeById,
        _setEmployeeActive = setEmployeeActive,
        super(const EmployeeDetailsState());

  final GetEmployeeById _getEmployeeById;
  final SetEmployeeActive _setEmployeeActive;

  String? _employeeId;

  Future<void> load(String id, {bool silent = false}) async {
    _employeeId = id;
    if (!silent) {
      emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    }
    final result = await _getEmployeeById(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: ViewStatus.failure, failure: failure),
      ),
      (employee) => emit(
        state.copyWith(
          status: ViewStatus.success,
          employee: employee,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> reload() async {
    final id = _employeeId;
    if (id != null) await load(id);
  }

  Future<void> setActive({required bool isActive}) async {
    final id = _employeeId;
    if (id == null || state.actionStatus == SubmissionStatus.submitting) return;
    emit(
      state.copyWith(
        actionStatus: SubmissionStatus.submitting,
        clearActionFailure: true,
      ),
    );
    final result = await _setEmployeeActive(
      SetEmployeeActiveParams(id: id, isActive: isActive),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: SubmissionStatus.failure,
          actionFailure: failure,
        ),
      ),
      (employee) => emit(
        state.copyWith(
          actionStatus: SubmissionStatus.success,
          employee: employee,
        ),
      ),
    );
  }
}

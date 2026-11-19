import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/usecases/employee_usecases.dart';

class EmployeeFormState extends Equatable {
  const EmployeeFormState({
    this.loadStatus = ViewStatus.initial,
    this.submitStatus = SubmissionStatus.idle,
    this.departments = const [],
    this.initial,
    this.loadFailure,
    this.submitFailure,
  });

  /// Loading of departments (and the employee, when editing).
  final ViewStatus loadStatus;
  final SubmissionStatus submitStatus;
  final List<Department> departments;

  /// The employee being edited; `null` when creating.
  final Employee? initial;
  final Failure? loadFailure;
  final Failure? submitFailure;

  EmployeeFormState copyWith({
    ViewStatus? loadStatus,
    SubmissionStatus? submitStatus,
    List<Department>? departments,
    Employee? initial,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    Failure? submitFailure,
    bool clearSubmitFailure = false,
  }) {
    return EmployeeFormState(
      loadStatus: loadStatus ?? this.loadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      departments: departments ?? this.departments,
      initial: initial ?? this.initial,
      loadFailure: clearLoadFailure ? null : (loadFailure ?? this.loadFailure),
      submitFailure:
          clearSubmitFailure ? null : (submitFailure ?? this.submitFailure),
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        submitStatus,
        departments,
        initial,
        loadFailure,
        submitFailure,
      ];
}

/// Drives both the "new employee" and "edit employee" screens.
class EmployeeFormCubit extends Cubit<EmployeeFormState> {
  EmployeeFormCubit({
    required GetDepartments getDepartments,
    required GetEmployeeById getEmployeeById,
    required CreateEmployee createEmployee,
    required UpdateEmployee updateEmployee,
  })  : _getDepartments = getDepartments,
        _getEmployeeById = getEmployeeById,
        _createEmployee = createEmployee,
        _updateEmployee = updateEmployee,
        super(const EmployeeFormState());

  final GetDepartments _getDepartments;
  final GetEmployeeById _getEmployeeById;
  final CreateEmployee _createEmployee;
  final UpdateEmployee _updateEmployee;

  String? _employeeId;

  bool get isEditing => _employeeId != null;

  /// Pass [employeeId] to edit; omit it to create.
  Future<void> init({String? employeeId}) async {
    _employeeId = employeeId;
    emit(
      state.copyWith(loadStatus: ViewStatus.loading, clearLoadFailure: true),
    );

    final departments = await _getDepartments(const NoParams());
    if (isClosed) return;
    final departmentFailure = departments.fold<Failure?>((f) => f, (_) => null);
    if (departmentFailure != null) {
      emit(
        state.copyWith(
          loadStatus: ViewStatus.failure,
          loadFailure: departmentFailure,
        ),
      );
      return;
    }
    final departmentList =
        departments.getOrElse((_) => const <Department>[]);

    Employee? employee;
    if (employeeId != null) {
      final result = await _getEmployeeById(employeeId);
      if (isClosed) return;
      final failure = result.fold<Failure?>((f) => f, (e) {
        employee = e;
        return null;
      });
      if (failure != null) {
        emit(
          state.copyWith(loadStatus: ViewStatus.failure, loadFailure: failure),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        loadStatus: ViewStatus.success,
        departments: departmentList,
        initial: employee,
      ),
    );
  }

  Future<void> submit(EmployeeDraft draft) async {
    if (state.submitStatus == SubmissionStatus.submitting) return;
    emit(
      state.copyWith(
        submitStatus: SubmissionStatus.submitting,
        clearSubmitFailure: true,
      ),
    );
    final id = _employeeId;
    final result = id == null
        ? await _createEmployee(draft)
        : await _updateEmployee(UpdateEmployeeParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: SubmissionStatus.failure,
          submitFailure: failure,
        ),
      ),
      (_) => emit(state.copyWith(submitStatus: SubmissionStatus.success)),
    );
  }
}

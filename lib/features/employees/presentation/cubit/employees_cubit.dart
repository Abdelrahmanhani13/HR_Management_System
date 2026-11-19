import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';
import 'package:hr_management/features/employees/domain/usecases/employee_usecases.dart';

class EmployeesState extends Equatable {
  const EmployeesState({
    this.status = ViewStatus.initial,
    this.employees = const [],
    this.departments = const [],
    this.query = const EmployeeQuery(),
    this.failure,
  });

  final ViewStatus status;
  final List<Employee> employees;
  final List<Department> departments;
  final EmployeeQuery query;
  final Failure? failure;

  EmployeesState copyWith({
    ViewStatus? status,
    List<Employee>? employees,
    List<Department>? departments,
    EmployeeQuery? query,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return EmployeesState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      departments: departments ?? this.departments,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, employees, departments, query, failure];
}

class EmployeesCubit extends Cubit<EmployeesState> {
  EmployeesCubit({
    required GetEmployees getEmployees,
    required GetDepartments getDepartments,
    this.searchDebounce = const Duration(milliseconds: 350),
  })  : _getEmployees = getEmployees,
        _getDepartments = getDepartments,
        super(const EmployeesState());

  final GetEmployees _getEmployees;
  final GetDepartments _getDepartments;
  final Duration searchDebounce;

  Timer? _debounce;
  int _requestId = 0;

  /// Loads the department filter options and the first page of employees.
  Future<void> init() async {
    unawaited(_loadDepartments());
    await load();
  }

  /// Loads employees for the current query. With [silent] the current list
  /// stays on screen (used for pull-to-refresh and returning from a detail).
  Future<void> load({bool silent = false}) async {
    final requestId = ++_requestId;
    if (!silent) {
      emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    }
    final result = await _getEmployees(state.query);
    // Ignore stale responses (the user changed filters meanwhile).
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: ViewStatus.failure, failure: failure),
      ),
      (employees) => emit(
        state.copyWith(
          status: ViewStatus.success,
          employees: employees,
          clearFailure: true,
        ),
      ),
    );
  }

  void search(String text) {
    _debounce?.cancel();
    emit(state.copyWith(query: state.query.copyWith(searchText: text)));
    _debounce = Timer(searchDebounce, load);
  }

  Future<void> setDepartment(String? departmentId) {
    _debounce?.cancel();
    emit(
      state.copyWith(
        query: departmentId == null
            ? state.query.copyWith(clearDepartment: true)
            : state.query.copyWith(departmentId: departmentId),
      ),
    );
    return load();
  }

  Future<void> setActiveFilter(EmployeeActiveFilter filter) {
    _debounce?.cancel();
    emit(state.copyWith(query: state.query.copyWith(activeFilter: filter)));
    return load();
  }

  Future<void> clearFilters() {
    _debounce?.cancel();
    emit(state.copyWith(query: const EmployeeQuery()));
    return load();
  }

  Future<void> _loadDepartments() async {
    final result = await _getDepartments(const NoParams());
    if (isClosed) return;
    // A department failure only hides the department filter; the list itself
    // reports its own errors.
    result.fold((_) {}, (departments) {
      emit(state.copyWith(departments: departments));
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';
import 'package:hr_management/features/employees/domain/repositories/employee_repository.dart';

class GetEmployees implements UseCase<List<Employee>, EmployeeQuery> {
  const GetEmployees(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, List<Employee>>> call(EmployeeQuery params) =>
      _repository.getEmployees(params);
}

class GetEmployeeById implements UseCase<Employee, String> {
  const GetEmployeeById(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, Employee>> call(String id) =>
      _repository.getEmployeeById(id);
}

class GetDepartments implements UseCase<List<Department>, NoParams> {
  const GetDepartments(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, List<Department>>> call(NoParams params) =>
      _repository.getDepartments();
}

class CreateEmployee implements UseCase<Employee, EmployeeDraft> {
  const CreateEmployee(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, Employee>> call(EmployeeDraft params) =>
      _repository.createEmployee(params);
}

class UpdateEmployeeParams extends Equatable {
  const UpdateEmployeeParams({required this.id, required this.draft});

  final String id;
  final EmployeeDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateEmployee implements UseCase<Employee, UpdateEmployeeParams> {
  const UpdateEmployee(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, Employee>> call(UpdateEmployeeParams params) =>
      _repository.updateEmployee(params.id, params.draft);
}

class SetEmployeeActiveParams extends Equatable {
  const SetEmployeeActiveParams({required this.id, required this.isActive});

  final String id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetEmployeeActive
    implements UseCase<Employee, SetEmployeeActiveParams> {
  const SetEmployeeActive(this._repository);

  final EmployeeRepository _repository;

  @override
  Future<Either<Failure, Employee>> call(SetEmployeeActiveParams params) =>
      _repository.setEmployeeActive(params.id, isActive: params.isActive);
}

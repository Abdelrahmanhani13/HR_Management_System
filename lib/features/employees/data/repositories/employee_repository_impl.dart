import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/employees/data/datasources/employee_remote_data_source.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';
import 'package:hr_management/features/employees/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  const EmployeeRepositoryImpl(this._remote);

  final EmployeeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Employee>>> getEmployees(EmployeeQuery query) =>
      guardCall<List<Employee>>(() => _remote.getEmployees(query));

  @override
  Future<Either<Failure, Employee>> getEmployeeById(String id) =>
      guardCall<Employee>(() => _remote.getEmployeeById(id));

  @override
  Future<Either<Failure, List<Department>>> getDepartments() =>
      guardCall<List<Department>>(_remote.getDepartments);

  @override
  Future<Either<Failure, Employee>> createEmployee(EmployeeDraft draft) =>
      guardCall<Employee>(() => _remote.createEmployee(draft));

  @override
  Future<Either<Failure, Employee>> updateEmployee(
    String id,
    EmployeeDraft draft,
  ) =>
      guardCall<Employee>(() => _remote.updateEmployee(id, draft));

  @override
  Future<Either<Failure, Employee>> setEmployeeActive(
    String id, {
    required bool isActive,
  }) =>
      guardCall<Employee>(
        () => _remote.setEmployeeActive(id, isActive: isActive),
      );
}

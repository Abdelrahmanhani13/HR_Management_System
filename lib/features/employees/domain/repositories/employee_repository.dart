import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/employees/domain/entities/department.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<Employee>>> getEmployees(EmployeeQuery query);

  Future<Either<Failure, Employee>> getEmployeeById(String id);

  Future<Either<Failure, List<Department>>> getDepartments();

  Future<Either<Failure, Employee>> createEmployee(EmployeeDraft draft);

  Future<Either<Failure, Employee>> updateEmployee(
    String id,
    EmployeeDraft draft,
  );

  /// Activates / deactivates an employee. Employees are never hard-deleted.
  Future<Either<Failure, Employee>> setEmployeeActive(
    String id, {
    required bool isActive,
  });
}

import 'package:hr_management/features/employees/data/models/department_model.dart';
import 'package:hr_management/features/employees/data/models/employee_model.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/employee_query.dart';

/// Contract for `employees` and `departments` access.
/// Implementations throw `AppException` subclasses.
abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees(EmployeeQuery query);

  Future<EmployeeModel> getEmployeeById(String id);

  Future<List<DepartmentModel>> getDepartments();

  Future<EmployeeModel> createEmployee(EmployeeDraft draft);

  Future<EmployeeModel> updateEmployee(String id, EmployeeDraft draft);

  Future<EmployeeModel> setEmployeeActive(String id, {required bool isActive});
}

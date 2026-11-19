import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/employees/domain/entities/gender.dart';

/// `public.employees` row. Column names match the SQL schema exactly.
class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.address,
    required super.dateOfBirth,
    required super.gender,
    required super.nationality,
    required super.phone,
    required super.nationalId,
    required super.contractDate,
    required super.salary,
    required super.checkInTime,
    required super.checkOutTime,
    required super.departmentId,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.departmentName,
    super.profileId,
  });

  /// TODO(supabase): confirm the select shape once queries exist. The joined
  /// department is expected as a nested object under `departments`
  /// (`{ "name": "..." }`); adjust the key if the query aliases it.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final department = json['departments'];
    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      address: json['address'] as String,
      dateOfBirth: AppFormat.parseSqlDate(json['date_of_birth'] as String),
      gender: Gender.fromValue(json['gender'] as String),
      nationality: json['nationality'] as String,
      phone: json['phone'] as String,
      nationalId: json['national_id'] as String,
      contractDate: AppFormat.parseSqlDate(json['contract_date'] as String),
      // `salary` is `numeric`; some clients return it as a string.
      salary: double.parse(json['salary'].toString()),
      checkInTime: ClockTime.parse(json['check_in_time'] as String),
      checkOutTime: ClockTime.parse(json['check_out_time'] as String),
      departmentId: json['department_id'] as String?,
      departmentName: department is Map<String, dynamic>
          ? department['name'] as String?
          : null,
      profileId: json['profile_id'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }
}

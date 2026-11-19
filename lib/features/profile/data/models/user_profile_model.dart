import 'package:hr_management/features/employees/data/models/employee_model.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';

/// `public.profiles` row. Column names match the SQL schema exactly.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.fullName,
    super.roleId,
    super.roleName,
    super.employee,
  });

  /// The role and linked employee are mapped from the nested query response.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final role = json['roles'];
    final employee = json['employee'];
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      roleId: json['role_id'] as String?,
      roleName: role is Map<String, dynamic> ? role['name'] as String? : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      employee: employee is Map<String, dynamic>
          ? EmployeeModel.fromJson(employee)
          : null,
    );
  }
}

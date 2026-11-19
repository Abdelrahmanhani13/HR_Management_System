import 'package:hr_management/features/employees/domain/entities/department.dart';

/// `public.departments` row.
class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.name,
    required super.isActive,
    super.description,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
    );
  }
}

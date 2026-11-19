import 'package:equatable/equatable.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';

/// Row of `public.profiles` (plus the joined role name) and the employee
/// record linked through `employees.profile_id`, if there is one.
///
/// The email is not part of `profiles`; it comes from the auth session.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.roleId,
    this.roleName,
    this.employee,
  });

  /// `profiles.id` (same as `auth.users.id`).
  final String id;

  /// `profiles.full_name` is nullable in the schema.
  final String? fullName;

  final String? roleId;

  /// Joined from `roles.name`, when the query included it.
  final String? roleName;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Employee whose `profile_id` equals [id]. `null` when none is linked.
  final Employee? employee;

  bool get hasLinkedEmployee => employee != null;

  /// Best available display name: profile name, then employee name.
  String? get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return employee?.fullName;
  }

  UserProfile copyWith({String? fullName, DateTime? updatedAt}) => UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        roleId: roleId,
        roleName: roleName,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        employee: employee,
      );

  @override
  List<Object?> get props =>
      [id, fullName, roleId, roleName, createdAt, updatedAt, employee];
}

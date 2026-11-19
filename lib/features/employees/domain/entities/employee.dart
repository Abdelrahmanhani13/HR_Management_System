import 'package:equatable/equatable.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';
import 'package:hr_management/features/employees/domain/entities/gender.dart';

/// Row of `public.employees` (plus the joined department name).
class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.fullName,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.phone,
    required this.nationalId,
    required this.contractDate,
    required this.salary,
    required this.checkInTime,
    required this.checkOutTime,
    required this.departmentId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.departmentName,
    this.profileId,
  });

  final String id;
  final String fullName;
  final String address;
  final DateTime dateOfBirth;
  final Gender gender;
  final String nationality;
  final String phone;
  final String nationalId;
  final DateTime contractDate;
  final double salary;

  /// Scheduled shift start / end (`employees.check_in_time` / `check_out_time`).
  final ClockTime checkInTime;
  final ClockTime checkOutTime;

  final String? departmentId;

  /// Name of the joined department, when the query included it.
  final String? departmentName;

  /// Linked login account (`employees.profile_id`), if any.
  final String? profileId;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasLinkedAccount => profileId != null;

  EmployeeDraft toDraft() => EmployeeDraft(
    fullName: fullName,
    address: address,
    dateOfBirth: dateOfBirth,
    gender: gender,
    nationality: nationality,
    phone: phone,
    nationalId: nationalId,
    contractDate: contractDate,
    salary: salary,
    checkInTime: checkInTime,
    checkOutTime: checkOutTime,
    departmentId: departmentId,
  );

  @override
  List<Object?> get props => [
    id,
    fullName,
    address,
    dateOfBirth,
    gender,
    nationality,
    phone,
    nationalId,
    contractDate,
    salary,
    checkInTime,
    checkOutTime,
    departmentId,
    departmentName,
    profileId,
    isActive,
    createdAt,
    updatedAt,
  ];
}

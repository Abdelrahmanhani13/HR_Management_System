import 'package:equatable/equatable.dart';
import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/features/employees/domain/entities/gender.dart';

/// Editable employee fields used for create and update.
///
/// Deliberately excludes `id`, timestamps, `is_active` (changed through its own
/// action) and `profile_id` (linking accounts belongs to user management,
/// which is out of scope).
class EmployeeDraft extends Equatable {
  const EmployeeDraft({
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
    this.departmentId,
  });

  final String fullName;
  final String address;
  final DateTime dateOfBirth;
  final Gender gender;
  final String nationality;
  final String phone;
  final String nationalId;
  final DateTime contractDate;
  final double salary;
  final ClockTime checkInTime;
  final ClockTime checkOutTime;
  final String? departmentId;

  @override
  List<Object?> get props => [
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
  ];
}

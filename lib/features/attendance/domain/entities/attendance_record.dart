import 'package:equatable/equatable.dart';
import 'package:hr_management/core/utils/clock_time.dart';

/// How the check-in compares with the employee's scheduled shift start.
enum ArrivalStatus { onTime, late, unknown }

/// Row of `public.attendance` plus joined employee data.
///
/// NOTE: the schema has no `status` column. [arrivalStatus] and
/// [workedDuration] are derived for display only: a check-in strictly after
/// `employees.check_in_time` counts as late (no grace period is assumed).
class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.checkIn,
    this.checkOut,
    this.employeeName,
    this.scheduledCheckIn,
    this.scheduledCheckOut,
  });

  final String id;
  final String employeeId;

  /// `attendance.attendance_date` (calendar day, local midnight).
  final DateTime date;
  final ClockTime checkIn;
  final ClockTime? checkOut;

  /// Joined from `employees.full_name`, when the query included it.
  final String? employeeName;

  /// Joined from `employees.check_in_time`, when the query included it.
  final ClockTime? scheduledCheckIn;
  final ClockTime? scheduledCheckOut;

  bool get isCheckedOut => checkOut != null;

  ArrivalStatus get arrivalStatus {
    final scheduled = scheduledCheckIn;
    if (scheduled == null) return ArrivalStatus.unknown;
    return checkIn.isAfter(scheduled)
        ? ArrivalStatus.late
        : ArrivalStatus.onTime;
  }

  bool get isEarlyDeparture {
    final actual = checkOut;
    final scheduled = scheduledCheckOut;
    return actual != null && scheduled != null && actual.isBefore(scheduled);
  }

  /// Time between check-in and check-out; `null` while still checked in (or
  /// when check-out is earlier than check-in, e.g. an overnight shift).
  Duration? get workedDuration {
    final out = checkOut;
    if (out == null) return null;
    final worked = out.asDuration - checkIn.asDuration;
    return worked.isNegative ? null : worked;
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    date,
    checkIn,
    checkOut,
    employeeName,
    scheduledCheckIn,
    scheduledCheckOut,
  ];
}

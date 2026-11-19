import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_draft.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/domain/entities/employee_option.dart';

/// `public.attendance` row. Column names match the SQL schema exactly.
class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.employeeId,
    required super.date,
    required super.checkIn,
    super.checkOut,
    super.employeeName,
    super.scheduledCheckIn,
    super.scheduledCheckOut,
  });

  /// TODO(supabase): confirm the select shape once queries exist. The joined
  /// employee is expected as a nested object under `employees`
  /// (`{ "full_name": "...", "check_in_time": "09:00:00" }`).
  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employees'];
    final checkOut = json['check_out'] as String?;
    final scheduled = employee is Map<String, dynamic>
        ? employee['check_in_time'] as String?
        : null;
    final scheduledCheckOut = employee is Map<String, dynamic>
        ? employee['check_out_time'] as String?
        : null;
    return AttendanceRecordModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      date: AppFormat.parseSqlDate(json['attendance_date'] as String),
      checkIn: ClockTime.parse(json['check_in'] as String),
      checkOut: checkOut == null ? null : ClockTime.parse(checkOut),
      employeeName: employee is Map<String, dynamic>
          ? employee['full_name'] as String?
          : null,
      scheduledCheckIn: scheduled == null ? null : ClockTime.parse(scheduled),
      scheduledCheckOut: scheduledCheckOut == null
          ? null
          : ClockTime.parse(scheduledCheckOut),
    );
  }
}

extension AttendanceDraftJson on AttendanceDraft {
  Map<String, dynamic> toJson() => {
    'employee_id': employeeId,
    'attendance_date': AppFormat.sqlDate(date),
    'check_in': checkIn.toSql(),
    'check_out': checkOut?.toSql(),
  };
}

class EmployeeOptionModel extends EmployeeOption {
  const EmployeeOptionModel({required super.id, required super.name});

  factory EmployeeOptionModel.fromJson(Map<String, dynamic> json) {
    return EmployeeOptionModel(
      id: json['id'] as String,
      name: json['full_name'] as String,
    );
  }
}

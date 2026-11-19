import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';

class PayrollReportRowModel extends PayrollReportRow {
  const PayrollReportRowModel({
    required super.employeeId,
    required super.fullName,
    required super.baseSalary,
    required super.presentDays,
    required super.absentDays,
    required super.overtimeHours,
    required super.lateHours,
    required super.overtimeAmount,
    required super.lateDeduction,
    required super.absenceDeduction,
    required super.netSalary,
    super.departmentName,
  });

  factory PayrollReportRowModel.fromJson(Map<String, dynamic> json) {
    return PayrollReportRowModel(
      employeeId: json['employee_id'] as String,
      fullName: json['full_name'] as String,
      departmentName: json['department_name'] as String?,
      baseSalary: _number(json['base_salary']).toDouble(),
      presentDays: _number(json['present_days']).toInt(),
      absentDays: _number(json['absent_days']).toInt(),
      overtimeHours: _number(json['overtime_hours']).toDouble(),
      lateHours: _number(json['late_hours']).toDouble(),
      overtimeAmount: _number(json['overtime_amount']).toDouble(),
      lateDeduction: _number(json['late_deduction']).toDouble(),
      absenceDeduction: _number(json['absence_deduction']).toDouble(),
      netSalary: _number(json['net_salary']).toDouble(),
    );
  }

  static num _number(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.parse(value);
    throw FormatException('Expected numeric payroll value, received $value');
  }
}

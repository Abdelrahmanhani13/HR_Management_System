import 'package:equatable/equatable.dart';

class PayrollReportRow extends Equatable {
  const PayrollReportRow({
    required this.employeeId,
    required this.fullName,
    required this.baseSalary,
    required this.presentDays,
    required this.absentDays,
    required this.overtimeHours,
    required this.lateHours,
    required this.overtimeAmount,
    required this.lateDeduction,
    required this.absenceDeduction,
    required this.netSalary,
    this.departmentName,
  });

  final String employeeId;
  final String fullName;
  final String? departmentName;
  final double baseSalary;
  final int presentDays;
  final int absentDays;
  final double overtimeHours;
  final double lateHours;
  final double overtimeAmount;
  final double lateDeduction;
  final double absenceDeduction;
  final double netSalary;

  @override
  List<Object?> get props => [
    employeeId,
    fullName,
    departmentName,
    baseSalary,
    presentDays,
    absentDays,
    overtimeHours,
    lateHours,
    overtimeAmount,
    lateDeduction,
    absenceDeduction,
    netSalary,
  ];
}

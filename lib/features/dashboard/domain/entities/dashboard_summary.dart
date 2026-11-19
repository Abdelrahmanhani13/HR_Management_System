import 'package:equatable/equatable.dart';

/// Aggregates for the dashboard. All values are derived from `employees` and
/// `attendance`; the schema has no stored statistics.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.checkedInToday,
    required this.lateToday,
    required this.checkedOutToday,
  });

  final int totalEmployees;
  final int activeEmployees;

  /// Attendance rows dated today (employees who checked in).
  final int checkedInToday;

  /// Of [checkedInToday], those who checked in after their shift start.
  final int lateToday;

  /// Of [checkedInToday], those who already checked out.
  final int checkedOutToday;

  int get inactiveEmployees => totalEmployees - activeEmployees;

  /// Checked in and not yet checked out.
  int get currentlyWorking => checkedInToday - checkedOutToday;

  /// Active employees without a record today.
  ///
  /// NOTE: this does not account for `official_holidays` or `weekly_off_days`,
  /// so on an off day it is not a real absence count; the UI labels it
  /// "Not checked in".
  int get notCheckedIn {
    final value = activeEmployees - checkedInToday;
    return value < 0 ? 0 : value;
  }

  @override
  List<Object?> get props => [
        totalEmployees,
        activeEmployees,
        checkedInToday,
        lateToday,
        checkedOutToday,
      ];
}

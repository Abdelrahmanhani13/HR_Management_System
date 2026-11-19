import 'package:equatable/equatable.dart';
import 'package:hr_management/core/utils/formatters.dart';

/// Filters for the attendance list. [from] and [to] are inclusive calendar days.
class AttendanceQuery extends Equatable {
  const AttendanceQuery({
    required this.from,
    required this.to,
    this.employeeId,
  });

  factory AttendanceQuery.today(DateTime now) {
    final day = dateOnly(now);
    return AttendanceQuery(from: day, to: day);
  }

  final DateTime from;
  final DateTime to;
  final String? employeeId;

  bool get isSingleDay => from == to;

  AttendanceQuery copyWith({
    DateTime? from,
    DateTime? to,
    String? employeeId,
    bool clearEmployee = false,
  }) {
    return AttendanceQuery(
      from: from ?? this.from,
      to: to ?? this.to,
      employeeId: clearEmployee ? null : (employeeId ?? this.employeeId),
    );
  }

  @override
  List<Object?> get props => [from, to, employeeId];
}

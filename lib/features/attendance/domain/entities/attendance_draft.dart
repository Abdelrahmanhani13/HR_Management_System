import 'package:equatable/equatable.dart';
import 'package:hr_management/core/utils/clock_time.dart';

class AttendanceDraft extends Equatable {
  const AttendanceDraft({
    required this.employeeId,
    required this.date,
    required this.checkIn,
    this.checkOut,
  });

  final String employeeId;
  final DateTime date;
  final ClockTime checkIn;
  final ClockTime? checkOut;

  @override
  List<Object?> get props => [employeeId, date, checkIn, checkOut];
}

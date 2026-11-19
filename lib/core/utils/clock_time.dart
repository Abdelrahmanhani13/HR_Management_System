import 'package:equatable/equatable.dart';

/// A time of day without a date, matching Postgres `time without time zone`
/// (used by `employees.check_in_time`, `attendance.check_in`, ...).
class ClockTime extends Equatable implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute, [this.second = 0])
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60),
      assert(second >= 0 && second < 60);

  /// Parses `HH:mm`, `HH:mm:ss` or `HH:mm:ss.SSS`.
  factory ClockTime.parse(String value) {
    final parts = value.split(':');
    if (parts.length < 2) {
      throw FormatException('Invalid time value: $value');
    }
    final seconds = parts.length > 2 ? double.parse(parts[2]).floor() : 0;
    return ClockTime(int.parse(parts[0]), int.parse(parts[1]), seconds);
  }

  factory ClockTime.fromDateTime(DateTime value) =>
      ClockTime(value.hour, value.minute, value.second);

  final int hour;
  final int minute;
  final int second;

  int get totalSeconds => hour * 3600 + minute * 60 + second;

  Duration get asDuration => Duration(seconds: totalSeconds);

  bool isBefore(ClockTime other) => totalSeconds < other.totalSeconds;

  bool isAfter(ClockTime other) => totalSeconds > other.totalSeconds;

  /// `HH:mm:ss`, the format Postgres expects for `time` columns.
  String toSql() => '${_two(hour)}:${_two(minute)}:${_two(second)}';

  @override
  int compareTo(ClockTime other) => totalSeconds.compareTo(other.totalSeconds);

  @override
  List<Object?> get props => [hour, minute, second];

  static String _two(int v) => v.toString().padLeft(2, '0');
}

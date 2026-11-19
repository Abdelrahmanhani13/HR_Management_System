import 'package:hr_management/core/utils/clock_time.dart';
import 'package:intl/intl.dart';

/// Central place for all date / time / number formatting.
class AppFormat {
  AppFormat._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateLong = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _clock = DateFormat('hh:mm a');
  static final NumberFormat _number = NumberFormat('#,##0.##');

  static String date(DateTime value) => _date.format(value);

  static String dateLong(DateTime value) => _dateLong.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());

  static String time(ClockTime value) =>
      _clock.format(DateTime(2000, 1, 1, value.hour, value.minute));

  /// `yyyy-MM-dd`, the format Postgres expects for `date` columns.
  ///
  /// Built by hand on purpose: `DateFormat` follows `Intl.defaultLocale`
  /// (set to `ar` in `main`) and would emit Arabic-Indic digits
  /// (`٢٠٢٦-١١-١٩`), which Postgres rejects with error 22007.
  static String sqlDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  /// Parses a Postgres `date` string into a local-midnight [DateTime].
  static DateTime parseSqlDate(String value) => DateTime.parse(value);

  static String number(num value) => _number.format(value);

  static String duration(Duration value) =>
      '${number(value.inHours)} س '
      '${number(value.inMinutes.remainder(60))} د';

  /// First letters of the first two words, upper-cased. `?` for empty names.
  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}

/// Strips the time part, keeping the local calendar day.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

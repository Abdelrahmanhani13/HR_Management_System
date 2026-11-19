import 'package:hr_management/core/utils/clock_time.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/validators.dart';
import 'package:hr_management/features/employees/domain/employee_rules.dart';

/// Form validators for the employee form, mirroring the table constraints.
class EmployeeValidators {
  EmployeeValidators._();

  static String? fullName(String? value) =>
      Validators.required(value, 'الاسم الكامل');

  static String? address(String? value) =>
      Validators.required(value, 'العنوان');

  static String? nationality(String? value) =>
      Validators.required(value, 'الجنسية');

  static String? phone(String? value) {
    final missing = Validators.required(value, 'رقم الهاتف');
    if (missing != null) return missing;
    if (!EmployeeRules.phonePattern.hasMatch(value!.trim())) {
      return 'أدخل 11 رقمًا على الأقل';
    }
    return null;
  }

  static String? nationalId(String? value) {
    final missing = Validators.required(value, 'الرقم القومي');
    if (missing != null) return missing;
    if (!EmployeeRules.nationalIdPattern.hasMatch(value!.trim())) {
      return 'أدخل 14 رقمًا على الأقل';
    }
    return null;
  }

  static String? salary(String? value) {
    final missing = Validators.required(value, 'الراتب');
    if (missing != null) return missing;
    final parsed = double.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null) return 'أدخل رقمًا صحيحًا';
    if (parsed <= EmployeeRules.minExclusiveSalary) {
      return 'يجب أن يكون الراتب أكبر من صفر';
    }
    return null;
  }

  static String? dateOfBirth(DateTime? value) =>
      value == null ? 'تاريخ الميلاد مطلوب' : null;

  static String? contractDate(DateTime? value) {
    if (value == null) return 'تاريخ العقد مطلوب';
    if (value.isBefore(EmployeeRules.minContractDate)) {
      return 'لا يمكن أن يسبق ${AppFormat.date(EmployeeRules.minContractDate)}';
    }
    return null;
  }

  static String? time(ClockTime? value, String label) =>
      value == null ? 'حقل $label مطلوب' : null;

  static String? gender(Object? value) =>
      value == null ? 'اختر النوع' : null;

  static String? department(String? value) =>
      value == null ? 'اختر القسم' : null;

  /// Parses a validated salary string.
  static double parseSalary(String value) =>
      double.parse(value.trim().replaceAll(',', ''));
}

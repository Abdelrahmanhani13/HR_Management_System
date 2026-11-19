import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/features/employees/domain/entities/employee_draft.dart';

/// Converts a draft to the column map used for insert / update payloads.
/// Keys are the exact `public.employees` column names.
extension EmployeeDraftJson on EmployeeDraft {
  Map<String, dynamic> toJson() => {
        'full_name': fullName.trim(),
        'address': address.trim(),
        'date_of_birth': AppFormat.sqlDate(dateOfBirth),
        'gender': gender.value,
        'nationality': nationality.trim(),
        'phone': phone.trim(),
        'national_id': nationalId.trim(),
        'contract_date': AppFormat.sqlDate(contractDate),
        'salary': salary,
        'check_in_time': checkInTime.toSql(),
        'check_out_time': checkOutTime.toSql(),
        'department_id': departmentId,
      };
}

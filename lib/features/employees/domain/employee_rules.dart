/// Validation rules that mirror the CHECK constraints of `public.employees`.
/// They exist for early, readable feedback only: the database remains the
/// authority and may still reject a value.
class EmployeeRules {
  EmployeeRules._();

  /// `phone ~ '^[0-9]{11,}$'`
  static final RegExp phonePattern = RegExp(r'^[0-9]{11,}$');

  /// `national_id ~ '^[0-9]{14,}$'`
  static final RegExp nationalIdPattern = RegExp(r'^[0-9]{14,}$');

  /// `contract_date >= '2008-01-01'`
  static final DateTime minContractDate = DateTime(2008, 1, 1);

  /// `salary > 0`
  static const double minExclusiveSalary = 0;
}

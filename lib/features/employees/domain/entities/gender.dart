/// Mirrors `employees.gender CHECK (gender IN ('male', 'female'))`.
enum Gender {
  male('male', 'ذكر'),
  female('female', 'أنثى');

  const Gender(this.value, this.label);

  /// The exact value stored in the database.
  final String value;
  final String label;

  static Gender fromValue(String value) {
    return Gender.values.firstWhere(
      (g) => g.value == value,
      orElse: () => throw FormatException('Unknown gender: $value'),
    );
  }
}

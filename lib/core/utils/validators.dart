/// Generic form validators. Feature-specific rules (which mirror database
/// CHECK constraints) live next to their feature.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const int minPasswordLength = 8;

  static String? required(String? value, [String? label]) {
    if (value == null || value.trim().isEmpty) {
      return label == null ? 'هذا الحقل مطلوب' : 'حقل $label مطلوب';
    }
    return null;
  }

  static String? email(String? value) {
    final missing = required(value, 'البريد الإلكتروني');
    if (missing != null) return missing;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }
    return null;
  }

  /// TODO(supabase): align with the password policy configured in Supabase Auth.
  static String? newPassword(String? value) {
    final missing = required(value, 'كلمة المرور');
    if (missing != null) return missing;
    if (value!.length < minPasswordLength) {
      return 'استخدم $minPasswordLength أحرف على الأقل';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final missing = required(value, 'تأكيد كلمة المرور');
    if (missing != null) return missing;
    if (value != original) return 'كلمتا المرور غير متطابقتين';
    return null;
  }
}

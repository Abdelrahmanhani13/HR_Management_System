import 'package:hr_management/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.userId, required super.email});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      userId: json['id'] as String,
      email: (json['email'] as String?) ?? '',
    );
  }
}

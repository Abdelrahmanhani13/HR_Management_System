import 'package:hr_management/features/auth/domain/entities/auth_session.dart';

class AuthStateChange {
  const AuthStateChange({
    required this.session,
    this.isPasswordRecovery = false,
  });

  final AuthSession? session;
  final bool isPasswordRecovery;
}

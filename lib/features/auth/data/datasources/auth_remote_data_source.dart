import 'package:hr_management/features/auth/data/models/auth_session_model.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';

/// Contract for everything that talks to Supabase Auth.
/// Implementations throw `AppException` subclasses, never return fake data.
abstract class AuthRemoteDataSource {
  Stream<AuthStateChange> authStateChanges();

  /// Returns the persisted session, or `null` when signed out.
  Future<AuthSessionModel?> getCurrentSession();

  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String newPassword);
}

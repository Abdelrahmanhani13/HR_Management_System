import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/auth/domain/entities/auth_session.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';

abstract class AuthRepository {
  /// Emits whenever the session changes (sign in, sign out, refresh, recovery).
  Stream<AuthStateChange> authStateChanges();

  /// Restores a persisted session on app start. `Right(null)` means "none".
  Future<Either<Failure, AuthSession?>> restoreSession();

  Future<Either<Failure, AuthSession>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  /// Sets a new password for the user in the current (recovery) session.
  Future<Either<Failure, Unit>> updatePassword(String newPassword);
}

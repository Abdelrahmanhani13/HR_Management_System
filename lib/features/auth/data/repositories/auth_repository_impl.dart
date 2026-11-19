import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hr_management/features/auth/domain/entities/auth_session.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';
import 'package:hr_management/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthStateChange> authStateChanges() => _remote.authStateChanges();

  @override
  Future<Either<Failure, AuthSession?>> restoreSession() =>
      guardCall<AuthSession?>(_remote.getCurrentSession);

  @override
  Future<Either<Failure, AuthSession>> signIn({
    required String email,
    required String password,
  }) => guardCall<AuthSession>(
    () => _remote.signIn(email: email, password: password),
  );

  @override
  Future<Either<Failure, Unit>> signOut() => guardCall<Unit>(() async {
    await _remote.signOut();
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) =>
      guardCall<Unit>(() async {
        await _remote.sendPasswordResetEmail(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> updatePassword(String newPassword) =>
      guardCall<Unit>(() async {
        await _remote.updatePassword(newPassword);
        return unit;
      });
}

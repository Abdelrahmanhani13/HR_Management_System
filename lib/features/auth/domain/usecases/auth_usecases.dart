import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/auth/domain/entities/auth_session.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';
import 'package:hr_management/features/auth/domain/repositories/auth_repository.dart';

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignIn implements UseCase<AuthSession, SignInParams> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(SignInParams params) =>
      _repository.signIn(email: params.email.trim(), password: params.password);
}

class SignOut implements UseCase<Unit, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.signOut();
}

class RestoreSession implements UseCase<AuthSession?, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession?>> call(NoParams params) =>
      _repository.restoreSession();
}

class ObserveAuthState {
  const ObserveAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthStateChange> call() => _repository.authStateChanges();
}

class SendPasswordResetEmail implements UseCase<Unit, String> {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendPasswordResetEmail(email.trim());
}

class UpdatePassword implements UseCase<Unit, String> {
  const UpdatePassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String newPassword) =>
      _repository.updatePassword(newPassword);
}

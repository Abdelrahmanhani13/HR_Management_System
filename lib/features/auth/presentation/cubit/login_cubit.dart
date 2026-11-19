import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/auth/domain/entities/auth_session.dart';
import 'package:hr_management/features/auth/domain/usecases/auth_usecases.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = SubmissionStatus.idle,
    this.session,
    this.failure,
  });

  final SubmissionStatus status;
  final AuthSession? session;
  final Failure? failure;

  @override
  List<Object?> get props => [status, session, failure];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn) : super(const LoginState());

  final SignIn _signIn;

  Future<void> submit({required String email, required String password}) async {
    if (state.status == SubmissionStatus.submitting) return;
    emit(const LoginState(status: SubmissionStatus.submitting));
    final result = await _signIn(
      SignInParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(
        LoginState(status: SubmissionStatus.failure, failure: failure),
      ),
      (session) => emit(
        LoginState(status: SubmissionStatus.success, session: session),
      ),
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/auth/domain/usecases/auth_usecases.dart';

/// Shared state for the two single-action password screens.
class PasswordActionState extends Equatable {
  const PasswordActionState({
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final SubmissionStatus status;
  final Failure? failure;

  @override
  List<Object?> get props => [status, failure];
}

class ForgotPasswordCubit extends Cubit<PasswordActionState> {
  ForgotPasswordCubit(this._sendResetEmail) : super(const PasswordActionState());

  final SendPasswordResetEmail _sendResetEmail;

  Future<void> submit(String email) async {
    if (state.status == SubmissionStatus.submitting) return;
    emit(const PasswordActionState(status: SubmissionStatus.submitting));
    final result = await _sendResetEmail(email);
    result.fold(
      (failure) => emit(
        PasswordActionState(status: SubmissionStatus.failure, failure: failure),
      ),
      (_) => emit(const PasswordActionState(status: SubmissionStatus.success)),
    );
  }
}

class ResetPasswordCubit extends Cubit<PasswordActionState> {
  ResetPasswordCubit(this._updatePassword) : super(const PasswordActionState());

  final UpdatePassword _updatePassword;

  Future<void> submit(String newPassword) async {
    if (state.status == SubmissionStatus.submitting) return;
    emit(const PasswordActionState(status: SubmissionStatus.submitting));
    final result = await _updatePassword(newPassword);
    result.fold(
      (failure) => emit(
        PasswordActionState(status: SubmissionStatus.failure, failure: failure),
      ),
      (_) => emit(const PasswordActionState(status: SubmissionStatus.success)),
    );
  }
}

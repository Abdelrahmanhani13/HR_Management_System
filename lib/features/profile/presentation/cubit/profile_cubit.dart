import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';
import 'package:hr_management/features/profile/domain/usecases/profile_usecases.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ViewStatus.initial,
    this.profile,
    this.failure,
  });

  final ViewStatus status;
  final UserProfile? profile;
  final Failure? failure;

  ProfileState copyWith({
    ViewStatus? status,
    UserProfile? profile,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, profile, failure];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetMyProfile getMyProfile})
    : _getMyProfile = getMyProfile,
      super(const ProfileState());

  final GetMyProfile _getMyProfile;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    }
    final result = await _getMyProfile(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ViewStatus.failure, failure: failure)),
      (profile) => emit(
        state.copyWith(
          status: ViewStatus.success,
          profile: profile,
          clearFailure: true,
        ),
      ),
    );
  }
}

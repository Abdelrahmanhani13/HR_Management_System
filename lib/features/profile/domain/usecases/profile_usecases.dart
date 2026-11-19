import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';
import 'package:hr_management/features/profile/domain/repositories/profile_repository.dart';

class GetMyProfile implements UseCase<UserProfile, NoParams> {
  const GetMyProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) =>
      _repository.getMyProfile();
}

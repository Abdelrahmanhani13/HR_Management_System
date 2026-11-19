import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';
import 'package:hr_management/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() =>
      guardCall<UserProfile>(_remote.getMyProfile);
}

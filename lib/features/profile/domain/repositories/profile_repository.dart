import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// The signed-in user's profile with the linked employee (if any).
  Future<Either<Failure, UserProfile>> getMyProfile();
}

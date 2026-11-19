import 'package:hr_management/features/profile/data/models/user_profile_model.dart';

/// Contract for `profiles` access (plus the linked employee).
/// Implementations throw `AppException` subclasses, never return fake data.
abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();
}

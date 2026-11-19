import 'package:hr_management/core/error/exceptions.dart';
import 'package:hr_management/core/error/supabase_error_mapper.dart';
import 'package:hr_management/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:hr_management/features/profile/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfileModel> getMyProfile() {
    return runSupabase(() async {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthAppException('انتهت الجلسة. سجّل الدخول مرة أخرى.');
      }
      final userId = user.id;

      final profile = await _client
          .from('profiles')
          .select('id, full_name, role_id, created_at, updated_at, roles(name)')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) {
        throw const NotFoundAppException('لم يتم العثور على ملفك الشخصي.');
      }

      // No linked employee (or no `employees.view`) simply returns no row:
      // that is not an error for the profile screen.
      final employee = await _client
          .from('employees')
          .select('*, departments(name)')
          .eq('profile_id', userId)
          .maybeSingle();

      final json = <String, dynamic>{...profile, 'employee': employee};
      final metadata = user.userMetadata ?? const <String, dynamic>{};
      final metadataName = metadata['full_name'] ?? metadata['name'];
      if (metadataName is String) json['full_name'] ??= metadataName;

      // `roles` is readable only with `roles.view`, so the embedded role name
      // can be null for custom roles. Fall back to the get_my_access RPC
      // (same one the manage-users Edge Function uses).
      if (json['roles'] == null) {
        final roleName = await _roleNameFromAccess();
        if (roleName != null) json['roles'] = {'name': roleName};
      }

      return UserProfileModel.fromJson(json);
    });
  }

  Future<String?> _roleNameFromAccess() async {
    try {
      final res = await _client.rpc('get_my_access');
      if (res is List && res.isNotEmpty && res.first is Map) {
        return (res.first as Map)['role_name'] as String?;
      }
    } catch (_) {
      // Optional enrichment only: never fail the profile because of it.
    }
    return null;
  }
}

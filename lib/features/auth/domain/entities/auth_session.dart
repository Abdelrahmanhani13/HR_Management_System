import 'package:equatable/equatable.dart';

/// The signed-in account. The email lives in `auth.users`, not in
/// `public.profiles`, so it is carried by the session.
class AuthSession extends Equatable {
  const AuthSession({required this.userId, required this.email});

  /// `auth.users.id` (also `profiles.id`).
  final String userId;
  final String email;

  @override
  List<Object?> get props => [userId, email];
}

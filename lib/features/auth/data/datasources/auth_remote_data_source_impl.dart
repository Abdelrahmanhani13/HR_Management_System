import 'package:hr_management/core/error/exceptions.dart';
import 'package:hr_management/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hr_management/features/auth/data/models/auth_session_model.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client, {String? authRedirectUrl})
    : _authRedirectUrl = authRedirectUrl;

  final SupabaseClient _client;
  final String? _authRedirectUrl;

  //* Handles Supabase authentication and session management.
  GoTrueClient get _auth => _client.auth;

  AuthSessionModel? _fromSession(Session? session) {
    final user = session?.user;
    if (user == null) return null;
    return AuthSessionModel(userId: user.id, email: user.email ?? '');
  }

  @override
  Stream<AuthStateChange> authStateChanges() => _auth.onAuthStateChange.map(
    (data) => AuthStateChange(
      session: _fromSession(data.session),
      isPasswordRecovery: data.event == AuthChangeEvent.passwordRecovery,
    ),
  );

  @override
  Future<AuthSessionModel?> getCurrentSession() async =>
      _fromSession(_auth.currentSession);

  @override
  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final model = _fromSession(res.session);
      if (model == null) {
        throw const AuthAppException(
          'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.',
        );
      }
      return model;
    } on AuthException catch (e) {
      throw AuthAppException(_authMessage(e, operation: 'تسجيل الدخول'));
    } on AppException {
      rethrow;
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw AuthAppException(_authMessage(e, operation: 'تسجيل الخروج'));
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: _authRedirectUrl);
    } on AuthException catch (e) {
      throw AuthAppException(
        _authMessage(e, operation: 'إرسال رابط استعادة كلمة المرور'),
      );
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthAppException(_authMessage(e, operation: 'تحديث كلمة المرور'));
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  String _authMessage(AuthException e, {required String operation}) {
    final code = e.code ?? '';
    final msg = e.message.toLowerCase();
    if (code == 'invalid_credentials' || msg.contains('invalid login')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (code == 'email_not_confirmed') {
      return 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';
    }
    if (code == 'weak_password' || msg.contains('password should be')) {
      return 'كلمة المرور ضعيفة. اختر كلمة مرور أقوى.';
    }
    if (code == 'otp_expired' || code == 'invalid_otp') {
      return 'رابط استعادة كلمة المرور غير صالح أو انتهت صلاحيته. اطلب رابطًا جديدًا.';
    }
    if (code == 'over_request_rate_limit' || e.statusCode == '429') {
      return 'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';
    }
    return 'تعذر $operation. يرجى المحاولة مرة أخرى.';
  }

  AppException _mapUnknown(Object e) {
    final t = e.toString().toLowerCase();
    if (t.contains('failed host lookup') ||
        t.contains('xmlhttprequest') ||
        t.contains('clientexception') ||
        t.contains('socket')) {
      return const NetworkAppException(
        'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.',
      );
    }
    return const ServerAppException(
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
    );
  }
}

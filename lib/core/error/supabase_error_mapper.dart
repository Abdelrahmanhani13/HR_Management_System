import 'package:flutter/foundation.dart';
import 'package:hr_management/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs a Supabase call and converts every failure into an [AppException]
/// (the repositories then turn those into `Failure`s through `guardCall`).
///
/// [uniqueFields] maps a column / constraint fragment (e.g. `phone`) to the
/// message shown when a unique constraint on it is violated.
/// [singleRowMessage] is used when `.single()` finds no row: with RLS that
/// means "missing OR not allowed", so the message should say both.
Future<T> runSupabase<T>(
  Future<T> Function() action, {
  Map<String, String> uniqueFields = const {},
  String singleRowMessage = 'السجل غير موجود أو ليس لديك صلاحية عليه.',
}) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on PostgrestException catch (e) {
    throw mapPostgrestException(
      e,
      uniqueFields: uniqueFields,
      singleRowMessage: singleRowMessage,
    );
  } on AuthException {
    throw const AuthAppException('انتهت الجلسة. سجّل الدخول مرة أخرى.');
  } catch (e) {
    throw mapUnknownError(e);
  }
}

AppException mapPostgrestException(
  PostgrestException e, {
  Map<String, String> uniqueFields = const {},
  String singleRowMessage = 'السجل غير موجود أو ليس لديك صلاحية عليه.',
}) {
  final code = e.code ?? '';
  final text = '${e.message} ${e.details ?? ''}'.toLowerCase();
  _logSupabaseError(e);

  switch (code) {
    // insufficient_privilege: also raised for "violates row-level security".
    case '42501':
      return const PermissionAppException('ليس لديك صلاحية لتنفيذ هذا الإجراء.');
    // JWT expired / invalid.
    case 'PGRST301':
    case 'PGRST303':
      return const AuthAppException('انتهت الجلسة. سجّل الدخول مرة أخرى.');
    // `.single()` / `.maybeSingle()` row-count mismatch.
    case 'PGRST116':
      return NotFoundAppException(singleRowMessage);
    // unique_violation
    case '23505':
      for (final entry in uniqueFields.entries) {
        if (text.contains(entry.key.toLowerCase())) {
          return ConflictAppException(entry.value);
        }
      }
      return const ConflictAppException('هذه البيانات موجودة بالفعل.');
    // invalid_datetime_format / datetime_field_overflow / invalid_text_
    // representation: the app sent a malformed value (a client bug, not
    // something the user can fix by retrying).
    case '22007':
    case '22008':
    case '22P02':
      return const ServerAppException(
        'تعذر إرسال البيانات بالصيغة الصحيحة. أبلغ فريق التطوير.',
      );
    // check_violation
    case '23514':
      return const ConflictAppException('قيمة غير صالحة. راجع البيانات المدخلة.');
    // not_null_violation
    case '23502':
      return const ConflictAppException('يوجد حقل مطلوب لم يتم إدخاله.');
    // foreign_key_violation
    case '23503':
      return const ConflictAppException(
        'لا يمكن تنفيذ العملية لارتباط هذا السجل ببيانات أخرى.',
      );
    // RAISE EXCEPTION from our own triggers / functions: the text is written
    // for humans (e.g. "Cannot record attendance on an official holiday").
    case 'P0001':
      if (e.message.startsWith('Not allowed') ||
          e.message.startsWith('Only an Admin')) {
        return PermissionAppException(e.message);
      }
      return ServerAppException(e.message);
  }
  return const ServerAppException('حدث خطأ في الخادم. حاول مرة أخرى.');
}

/// Debug builds only: prints what the server really said, because the
/// messages shown to the user are deliberately generic. Never logs in release.
void _logSupabaseError(PostgrestException e) {
  if (!kDebugMode) return;
  debugPrint(
    '[supabase] code=${e.code} message=${e.message} '
    'details=${e.details} hint=${e.hint}',
  );
}

AppException mapUnknownError(Object e) {
  if (kDebugMode) debugPrint('[supabase] unexpected error: $e');
  final t = e.toString().toLowerCase();
  if (t.contains('failed host lookup') ||
      t.contains('xmlhttprequest') ||
      t.contains('clientexception') ||
      t.contains('socket') ||
      t.contains('timeout')) {
    return const NetworkAppException(
      'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.',
    );
  }
  return const ServerAppException('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
}

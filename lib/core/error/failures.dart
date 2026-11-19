import 'package:equatable/equatable.dart';

/// Domain-level error returned on the left side of `Either<Failure, T>`.
/// [message] is always safe to show to the user.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The data source for this operation is still a placeholder.
class NotImplementedFailure extends Failure {
  const NotImplementedFailure([this.operation = ''])
    : super('هذه الوظيفة غير متصلة بالخادم بعد.');

  final String operation;

  @override
  List<Object?> get props => [message, operation];
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'تعذر التحقق من بيانات تسجيل الدخول.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'ليست لديك صلاحية لتنفيذ هذا الإجراء.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'لم يتم العثور على السجل المطلوب.',
  ]);
}

class ConflictFailure extends Failure {
  const ConflictFailure([
    super.message = 'تتعارض البيانات مع سجل موجود بالفعل.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم. حاول مرة أخرى.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'حدث خطأ غير متوقع.']);
}

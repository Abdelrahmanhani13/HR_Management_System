import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/exceptions.dart';
import 'package:hr_management/core/error/failures.dart';

/// Runs a data-source call and converts any thrown error into a [Failure].
Future<Either<Failure, T>> guardCall<T>(Future<T> Function() action) async {
  try {
    return Right<Failure, T>(await action());
  } on AppException catch (e) {
    return Left<Failure, T>(failureFromException(e));
  } catch (_) {
    return Left<Failure, T>(const UnexpectedFailure());
  }
}

Failure failureFromException(AppException e) {
  if (e is NotImplementedAppException) {
    return NotImplementedFailure(e.operation);
  }
  if (e is AuthAppException) {
    return AuthFailure(e.message);
  }
  if (e is PermissionAppException) {
    return PermissionFailure(e.message);
  }
  if (e is NotFoundAppException) {
    return NotFoundFailure(e.message);
  }
  if (e is ConflictAppException) {
    return ConflictFailure(e.message);
  }
  if (e is NetworkAppException) {
    return NetworkFailure(e.message);
  }
  return ServerFailure(e.message);
}

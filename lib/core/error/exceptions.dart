/// Exceptions thrown by remote data sources.
///
/// Repositories catch these (see `guardCall`) and convert them to `Failure`s,
/// so presentation code never sees an exception.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown by every data-source method whose Supabase integration has not been
/// written yet. It is NOT a fake success: the UI shows an honest
/// "not connected yet" state.
class NotImplementedAppException extends AppException {
  const NotImplementedAppException(this.operation)
    : super('Not implemented yet: $operation');

  /// Dotted name of the pending operation, e.g. `employees.getEmployees`.
  final String operation;
}

class AuthAppException extends AppException {
  const AuthAppException(super.message);
}

class PermissionAppException extends AppException {
  const PermissionAppException(super.message);
}

class NotFoundAppException extends AppException {
  const NotFoundAppException(super.message);
}

/// Unique / check-constraint violations (e.g. duplicate phone or national id).
class ConflictAppException extends AppException {
  const ConflictAppException(super.message);
}

class NetworkAppException extends AppException {
  const NetworkAppException(super.message);
}

class ServerAppException extends AppException {
  const ServerAppException(super.message);
}

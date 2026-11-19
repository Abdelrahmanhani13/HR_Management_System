import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';

/// A single application action. Keep implementations thin: they delegate to a
/// repository and hold no state.
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

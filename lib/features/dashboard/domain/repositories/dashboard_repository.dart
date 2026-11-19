import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  /// Summary for the given calendar [day].
  Future<Either<Failure, DashboardSummary>> getSummary(DateTime day);
}

import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:hr_management/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummary implements UseCase<DashboardSummary, DateTime> {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardSummary>> call(DateTime day) =>
      _repository.getSummary(day);
}

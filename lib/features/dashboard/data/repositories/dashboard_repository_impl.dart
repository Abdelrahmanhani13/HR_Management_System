import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:hr_management/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary(DateTime day) =>
      guardCall<DashboardSummary>(() => _remote.getSummary(day));
}

import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/error/guard.dart';
import 'package:hr_management/features/payroll/data/datasources/payroll_remote_data_source.dart';
import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';
import 'package:hr_management/features/payroll/domain/repositories/payroll_repository.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  const PayrollRepositoryImpl(this._remote);

  final PayrollRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PayrollReportRow>>> getReport({
    required int year,
    required int month,
  }) => guardCall<List<PayrollReportRow>>(
    () => _remote.getReport(year: year, month: month),
  );
}

import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';
import 'package:hr_management/features/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollReport {
  const GetPayrollReport(this._repository);

  final PayrollRepository _repository;

  Future<Either<Failure, List<PayrollReportRow>>> call({
    required int year,
    required int month,
  }) => _repository.getReport(year: year, month: month);
}

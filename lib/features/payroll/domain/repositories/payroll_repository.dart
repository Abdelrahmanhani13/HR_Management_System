import 'package:fpdart/fpdart.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';

abstract class PayrollRepository {
  Future<Either<Failure, List<PayrollReportRow>>> getReport({
    required int year,
    required int month,
  });
}

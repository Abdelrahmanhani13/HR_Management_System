import 'package:hr_management/features/payroll/data/models/payroll_report_row_model.dart';

abstract class PayrollRemoteDataSource {
  Future<List<PayrollReportRowModel>> getReport({
    required int year,
    required int month,
  });
}

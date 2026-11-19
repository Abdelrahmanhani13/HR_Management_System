import 'package:hr_management/core/error/supabase_error_mapper.dart';
import 'package:hr_management/features/payroll/data/datasources/payroll_remote_data_source.dart';
import 'package:hr_management/features/payroll/data/models/payroll_report_row_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  const PayrollRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PayrollReportRowModel>> getReport({
    required int year,
    required int month,
  }) {
    return runSupabase(() async {
      final response = await _client.rpc(
        'get_payroll_report',
        params: {'p_year': year, 'p_month': month},
      );
      if (response is! List) {
        throw const FormatException(
          'get_payroll_report returned an unexpected response.',
        );
      }
      return response.map((row) {
        if (row is! Map) {
          throw const FormatException(
            'get_payroll_report returned an invalid row.',
          );
        }
        return PayrollReportRowModel.fromJson(Map<String, dynamic>.from(row));
      }).toList();
    });
  }
}

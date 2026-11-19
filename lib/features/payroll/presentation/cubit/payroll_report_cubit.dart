import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';
import 'package:hr_management/features/payroll/domain/usecases/get_payroll_report.dart';

class PayrollReportState extends Equatable {
  const PayrollReportState({
    required this.year,
    required this.month,
    this.status = ViewStatus.initial,
    this.rows = const [],
    this.failure,
  });

  final int year;
  final int month;
  final ViewStatus status;
  final List<PayrollReportRow> rows;
  final Failure? failure;

  PayrollReportState copyWith({
    int? year,
    int? month,
    ViewStatus? status,
    List<PayrollReportRow>? rows,
    Failure? failure,
    bool clearFailure = false,
  }) => PayrollReportState(
    year: year ?? this.year,
    month: month ?? this.month,
    status: status ?? this.status,
    rows: rows ?? this.rows,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [year, month, status, rows, failure];
}

class PayrollReportCubit extends Cubit<PayrollReportState> {
  PayrollReportCubit({
    required GetPayrollReport getPayrollReport,
    DateTime Function()? now,
  }) : _getPayrollReport = getPayrollReport,
       _now = now ?? DateTime.now,
       super(
         PayrollReportState(
           year: (now ?? DateTime.now)().year,
           month: (now ?? DateTime.now)().month,
         ),
       );

  final GetPayrollReport _getPayrollReport;
  final DateTime Function() _now;
  int _requestId = 0;

  Future<void> load({bool silent = false}) async {
    final requestId = ++_requestId;
    if (!silent) {
      emit(state.copyWith(status: ViewStatus.loading, clearFailure: true));
    }
    final result = await _getPayrollReport(
      year: state.year,
      month: state.month,
    );
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ViewStatus.failure, failure: failure)),
      (rows) => emit(
        state.copyWith(
          status: ViewStatus.success,
          rows: rows,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> previousMonth() async {
    if (state.year == 2008 && state.month == 1) return;
    final previous = DateTime(state.year, state.month - 1);
    emit(state.copyWith(year: previous.year, month: previous.month));
    await load();
  }

  Future<void> nextMonth() async {
    final current = _now();
    if (state.year == current.year && state.month >= current.month) return;
    final next = DateTime(state.year, state.month + 1);
    emit(state.copyWith(year: next.year, month: next.month));
    await load();
  }
}

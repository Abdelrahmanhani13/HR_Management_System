import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:hr_management/features/dashboard/domain/usecases/get_dashboard_summary.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.status = ViewStatus.initial,
    this.summary,
    this.failure,
  });

  final ViewStatus status;
  final DashboardSummary? summary;
  final Failure? failure;

  @override
  List<Object?> get props => [status, summary, failure];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getSummary, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const DashboardState());

  final GetDashboardSummary _getSummary;
  final DateTime Function() _now;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(const DashboardState(status: ViewStatus.loading));
    final result = await _getSummary(dateOnly(_now()));
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        DashboardState(
          status: ViewStatus.failure,
          failure: failure,
          summary: state.summary,
        ),
      ),
      (summary) => emit(
        DashboardState(status: ViewStatus.success, summary: summary),
      ),
    );
  }
}

import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalEmployees,
    required super.activeEmployees,
    required super.checkedInToday,
    required super.lateToday,
    required super.checkedOutToday,
  });

  /// TODO(supabase): only needed if the aggregates come back as one JSON
  /// object (for example from a view or RPC you add later). If the counts are
  /// computed on the client from list queries, build the model directly.
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalEmployees: json['total_employees'] as int,
      activeEmployees: json['active_employees'] as int,
      checkedInToday: json['checked_in_today'] as int,
      lateToday: json['late_today'] as int,
      checkedOutToday: json['checked_out_today'] as int,
    );
  }
}

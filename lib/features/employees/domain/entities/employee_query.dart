import 'package:equatable/equatable.dart';

enum EmployeeActiveFilter {
  all('كل الحالات'),
  active('نشط'),
  inactive('غير نشط');

  const EmployeeActiveFilter(this.label);

  final String label;
}

/// Search + filter criteria for the employees list.
class EmployeeQuery extends Equatable {
  const EmployeeQuery({
    this.searchText = '',
    this.departmentId,
    this.activeFilter = EmployeeActiveFilter.all,
  });

  /// Matched against name, phone and national id by the data source.
  final String searchText;
  final String? departmentId;
  final EmployeeActiveFilter activeFilter;

  bool get hasFilters =>
      searchText.trim().isNotEmpty ||
      departmentId != null ||
      activeFilter != EmployeeActiveFilter.all;

  EmployeeQuery copyWith({
    String? searchText,
    String? departmentId,
    bool clearDepartment = false,
    EmployeeActiveFilter? activeFilter,
  }) {
    return EmployeeQuery(
      searchText: searchText ?? this.searchText,
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [searchText, departmentId, activeFilter];
}

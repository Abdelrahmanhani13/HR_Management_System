import 'package:equatable/equatable.dart';

/// Minimal employee info for the attendance employee filter.
class EmployeeOption extends Equatable {
  const EmployeeOption({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

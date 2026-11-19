import 'package:equatable/equatable.dart';

/// Row of `public.departments`.
class Department extends Equatable {
  const Department({
    required this.id,
    required this.name,
    required this.isActive,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, description, isActive];
}

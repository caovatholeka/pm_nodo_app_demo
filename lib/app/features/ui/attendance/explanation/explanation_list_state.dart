import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';

class WorkEntryState extends Equatable {
  final bool isLoading;
  final List<WorkEntryEntity> list;
  final String? error;

  const WorkEntryState({
    this.isLoading = false,
    this.list = const [],
    this.error,
  });

  WorkEntryState copyWith({
    bool? isLoading,
    List<WorkEntryEntity>? list,
    String? error,
  }) {
    return WorkEntryState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, list, error];
}

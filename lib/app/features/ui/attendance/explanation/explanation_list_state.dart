part of 'explanation_list_cubit.dart';

class ExplanationListState extends Equatable {
  final LoadStatus loadStatus;
  final bool isLoading;
  final List<WorkEntryEntity> list;
  final String? error;

  const ExplanationListState({
    this.loadStatus = LoadStatus.INITIAL,
    this.isLoading = false,
    this.list = const [],
    this.error,
  });

  ExplanationListState copyWith({
    LoadStatus? loadStatus,
    bool? isLoading,
    List<WorkEntryEntity>? list,
    String? error,
  }) {
    return ExplanationListState(
      loadStatus: loadStatus ?? this.loadStatus,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loadStatus,isLoading, list, error];
}

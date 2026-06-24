part of 'checkpoint_cubit.dart';

class CheckpointState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus loadSubmitStatus;
  final List<CheckpointEntity> listCheckpoint;
  final String? startDateFilter;
  final String? endDateFilter;
  final String? error;

  const CheckpointState({
    this.loadDataStatus = LoadStatus.INITIAL,
    this.loadSubmitStatus = LoadStatus.INITIAL,
    this.listCheckpoint = const [],
    this.startDateFilter,
    this.endDateFilter,
    this.error,
  });

  CheckpointState copyWith({
    LoadStatus? loadDataStatus,
    LoadStatus? loadSubmitStatus,
    List<CheckpointEntity>? listCheckpoint,
    String? startDateFilter,
    String? endDateFilter,
    String? error,
  }) {
    return CheckpointState(
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      loadSubmitStatus: loadSubmitStatus ?? this.loadSubmitStatus,
      listCheckpoint: listCheckpoint ?? this.listCheckpoint,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    loadDataStatus,
    loadSubmitStatus,
    listCheckpoint,
    startDateFilter,
    endDateFilter,
    error,
  ];
}

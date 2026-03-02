part of 'justification_cubit.dart';

class JustificationState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final LoadStatus submitStatus;
  final LoadStatus deleteStatus;
  final List<JustificationEntity> list;
  final String? error;
  

  const JustificationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.submitStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
  });

  JustificationState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    LoadStatus? submitStatus,
    LoadStatus? deleteStatus,
    List<JustificationEntity>? list,
    String? error,
  }) {
    return JustificationState(
      loadStatus: loadStatus ?? this.loadStatus,
      list: list ?? this.list,
      error: error,
      approveStatus: approveStatus ?? this.approveStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error, approveStatus, submitStatus, deleteStatus];
}

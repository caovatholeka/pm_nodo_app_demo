part of 'justification_cubit.dart';

class JustificationState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final List<JustificationEntity> list;
  final String? error;
  

  const JustificationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
  });

  JustificationState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    List<JustificationEntity>? list,
    String? error,
  }) {
    return JustificationState(
      loadStatus: loadStatus ?? this.loadStatus,
      list: list ?? this.list,
      error: error,
      approveStatus: approveStatus ?? this.approveStatus,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error, approveStatus];
}

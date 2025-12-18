part of 'justification_cubit.dart';

class JustificationState extends Equatable {
  final LoadStatus loadStatus;
  final List<JustificationEntity> list;
  final String? error;
  

  const JustificationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
  });

  JustificationState copyWith({
    LoadStatus? loadStatus,
    List<JustificationEntity>? list,
    String? error,
  }) {
    return JustificationState(
      loadStatus: loadStatus ?? this.loadStatus,
      list: list ?? this.list,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error];
}

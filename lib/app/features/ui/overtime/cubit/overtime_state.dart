part of 'overtime_cubit.dart';

class OvertimeState extends Equatable {
  final LoadStatus loadStatus;
  final List<OvertimeEntity> list;
  final String? error;

  const OvertimeState({
    this.loadStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
  });

  OvertimeState copyWith({
    LoadStatus? loadStatus,
    List<OvertimeEntity>? list,
    String? error,
  }) {
    return OvertimeState(
      loadStatus: loadStatus ?? this.loadStatus,
      list: list ?? this.list,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error];
}

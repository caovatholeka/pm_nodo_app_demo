part of 'overtime_cubit.dart';

class OvertimeState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final List<OvertimeEntity> list;
  final String? error;

  const OvertimeState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
  });

  OvertimeState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    List<OvertimeEntity>? list,
    String? error,
  }) {
    return OvertimeState(
      loadStatus: loadStatus ?? this.loadStatus,
      approveStatus: approveStatus ?? this.approveStatus,
      list: list ?? this.list,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error, approveStatus];
}

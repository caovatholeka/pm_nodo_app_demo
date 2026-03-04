part of 'overtime_cubit.dart';

class OvertimeState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus approveStatus;
  final LoadStatus submitStatus;
  final List<OvertimeEntity> list;
  final String? error;

  const OvertimeState({
    this.loadStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.list = const [],
    this.error,
    this.submitStatus = LoadStatus.INITIAL,
  });

  OvertimeState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? approveStatus,
    List<OvertimeEntity>? list,
    String? error,
    LoadStatus? submitStatus,
  }) {
    return OvertimeState(
      loadStatus: loadStatus ?? this.loadStatus,
      approveStatus: approveStatus ?? this.approveStatus,
      list: list ?? this.list,
      error: error ?? this.error,
      submitStatus: submitStatus ?? this.submitStatus,
    );
  }

  @override
  List<Object?> get props => [loadStatus, list, error, approveStatus, submitStatus];
}

part of 'justification_detail_cubit.dart';

class JustificationDetailState extends Equatable {
  final LoadStatus loadStatus;
  final JustificationEntity? detail;

  const JustificationDetailState({
    this.loadStatus = LoadStatus.INITIAL,
    this.detail,
  });

  JustificationDetailState copyWith({
    LoadStatus? loadStatus,
    JustificationEntity? detail,
  }) {
    return JustificationDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      detail: detail ?? this.detail,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        detail,
      ];
}

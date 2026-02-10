part of 'detail_on_leave_cubit.dart';

class DetailOnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus deleteStatus;
  final LoadStatus confirmStatus;
  final LoadStatus approveStatus;
  final LoadStatus rejectStatus;
  OnLeaveEntity? detailEntity;

  DetailOnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.confirmStatus = LoadStatus.INITIAL,
    this.approveStatus = LoadStatus.INITIAL,
    this.rejectStatus = LoadStatus.INITIAL,
    this.detailEntity,
  });

  DetailOnLeaveState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? deleteStatus,
    LoadStatus? confirmStatus,
    LoadStatus? approveStatus,
    LoadStatus? rejectStatus,
    OnLeaveEntity? detailEntity,
  }) {
    return DetailOnLeaveState(
      loadStatus: loadStatus ?? this.loadStatus,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      detailEntity: detailEntity ?? this.detailEntity,
      approveStatus: approveStatus ?? this.approveStatus,
      rejectStatus: rejectStatus ?? this.rejectStatus,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    confirmStatus,
    deleteStatus,
    detailEntity,
    approveStatus,
    rejectStatus,
  ];
}
part of 'detail_on_leave_cubit.dart';

class DetailOnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus deleteStatus;
  final LoadStatus confirmStatus;
  OnLeaveEntity? detailEntity;

  DetailOnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.confirmStatus = LoadStatus.INITIAL,
    this.detailEntity
  });

  DetailOnLeaveState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? deleteStatus,
    LoadStatus? confirmStatus,
    OnLeaveEntity? detailEntity
  }) {
    return DetailOnLeaveState(
      loadStatus: loadStatus ?? this.loadStatus,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      detailEntity: detailEntity ?? this.detailEntity
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    confirmStatus,
    deleteStatus,
    detailEntity,
  ];
}
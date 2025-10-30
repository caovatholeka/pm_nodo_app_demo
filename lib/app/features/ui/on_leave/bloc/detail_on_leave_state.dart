part of 'detail_on_leave_cubit.dart';

class DetailOnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus deleteStatus;
  OnLeaveEntity? detailEntity;

  DetailOnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.detailEntity
  });

  DetailOnLeaveState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? deleteStatus,
    OnLeaveEntity? detailEntity
  }) {
    return DetailOnLeaveState(
      loadStatus: loadStatus ?? this.loadStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      detailEntity: detailEntity ?? this.detailEntity
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    deleteStatus,
    detailEntity,
  ];
}
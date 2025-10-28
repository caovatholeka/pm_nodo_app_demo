part of 'detail_on_leave_cubit.dart';

class DetailOnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  OnLeaveEntity? detailEntity;

  DetailOnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.detailEntity
  });

  DetailOnLeaveState copyWith({
    LoadStatus? loadStatus,
    OnLeaveEntity? detailEntity
  }) {
    return DetailOnLeaveState(
      loadStatus: loadStatus ?? this.loadStatus,
      detailEntity: detailEntity ?? this.detailEntity
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    detailEntity,
  ];
}
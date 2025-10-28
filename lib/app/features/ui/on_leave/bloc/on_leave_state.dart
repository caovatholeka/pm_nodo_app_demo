part of 'on_leave_cubit.dart';

class OnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus createStatus;
  final LoadStatus updateStatus;
  final LoadStatus deleteStatus;
  String? errMsg;
  String? errStatus;

  final List<OnLeaveEntity>? listLeaveEntities;
  final OnLeaveEntity? detailOnLeave;

  OnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.createStatus = LoadStatus.INITIAL,
    this.updateStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,
    this.errMsg,
    this.errStatus,
    this.listLeaveEntities,
    this.detailOnLeave,
  });

  OnLeaveState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    LoadStatus? createStatus,
    LoadStatus? updateStatus,
    LoadStatus? deleteStatus,
    String? errMsg,
    String? errStatus,
    List<OnLeaveEntity>? listLeaveEntities,
    OnLeaveEntity? detailOnLeave,
  }) {
    return OnLeaveState(
        loadStatus: loadStatus ?? this.loadStatus,
        createStatus: createStatus ?? this.createStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        errMsg: errMsg ?? this.errMsg,
        errStatus: errStatus ?? this.errStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        listLeaveEntities: listLeaveEntities ?? this.listLeaveEntities,
        detailOnLeave: detailOnLeave ?? this.detailOnLeave,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    createStatus,
    updateStatus,
    deleteStatus,
    errMsg,
    errStatus,
    listLeaveEntities,
    detailOnLeave,
  ];
}
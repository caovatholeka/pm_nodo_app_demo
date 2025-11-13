part of 'on_leave_cubit.dart';

class OnLeaveState extends Equatable {
  final LoadStatus loadStatus;
  String? errMsg;
  String? errStatus;

  final List<OnLeaveEntity>? listLeaveEntities;
  final OnLeaveEntity? detailOnLeave;

  String? startDateFilter;
  String? endDateFilter;


  OnLeaveState({
    this.loadStatus = LoadStatus.INITIAL,
    this.errMsg,
    this.errStatus,
    this.listLeaveEntities,
    this.detailOnLeave,
    this.startDateFilter,
    this.endDateFilter
  });

  OnLeaveState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    String? errMsg,
    String? errStatus,
    List<OnLeaveEntity>? listLeaveEntities,
    OnLeaveEntity? detailOnLeave,
    String? startDateFilter,
    String? endDateFilter
  }) {
    return OnLeaveState(
        loadStatus: loadStatus ?? this.loadStatus,
        errMsg: errMsg ?? this.errMsg,
        errStatus: errStatus ?? this.errStatus,
        listLeaveEntities: listLeaveEntities ?? this.listLeaveEntities,
        detailOnLeave: detailOnLeave ?? this.detailOnLeave,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    errMsg,
    errStatus,
    listLeaveEntities,
    detailOnLeave,
    startDateFilter,
    endDateFilter
  ];
}

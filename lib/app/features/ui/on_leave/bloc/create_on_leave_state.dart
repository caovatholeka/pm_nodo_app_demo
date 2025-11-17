part of 'create_on_leave_cubit.dart';

class CreateOnLeaveState extends Equatable {
  final LoadStatus createStatus;
  String? leaveDateType;
  String? leaveType;
  DateTime? fromDateTime;
  DateTime? toDateTime;
  String? fromDate;
  String? toDate;
  String? reason;
  String? leaveDays;

  // loại ngày nghỉ
  List<MasterDataItem>? listDateTypeLeaves;
  MasterDataItem? currentDateLeaveType;

  // số ngày nghỉ
  List<LeaveDayEntity>? listLeaveDays;

  // loại nghỉ
  List<MasterDataItem>? listTypeLeaves;
  MasterDataItem? currentLeaveType;

  CreateOnLeaveState({
    this.createStatus = LoadStatus.INITIAL,
    this.leaveDateType,
    this.leaveType,
    this.fromDateTime,
    this.toDateTime,
    this.fromDate,
    this.toDate,
    this.reason,
    this.leaveDays,
    this.listDateTypeLeaves,
    this.currentDateLeaveType,
    this.listTypeLeaves,
    this.currentLeaveType,
    this.listLeaveDays
  });

  CreateOnLeaveState copyWith({
    bool resetDateTime = false,
    LoadStatus? createStatus,
    String? leaveDateType,
    String? leaveType,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    String? fromDate,
    String? toDate,
    String? reason,
    String? leaveDays,
    List<MasterDataItem>? listDateTypeLeaves,
    MasterDataItem? currentDateLeaveType,

    List<LeaveDayEntity>? listLeaveDays,

    List<MasterDataItem>? listTypeLeaves,
    MasterDataItem? currentLeaveType,
  }) {
    return CreateOnLeaveState(
      createStatus: createStatus ?? this.createStatus,
      leaveDateType: leaveDateType ?? this.leaveDateType,
      leaveType: leaveType ?? this.leaveType,
      fromDateTime: resetDateTime ? null : (fromDateTime ?? this.fromDateTime),
      toDateTime: resetDateTime ? null : (toDateTime ?? this.toDateTime),
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      leaveDays: leaveDays ?? this.leaveDays,
      listDateTypeLeaves: listDateTypeLeaves ?? this.listDateTypeLeaves,
      currentDateLeaveType: currentDateLeaveType ?? this.currentDateLeaveType,
      listLeaveDays: listLeaveDays ?? this.listLeaveDays,
      listTypeLeaves: listTypeLeaves ?? this.listTypeLeaves,
      currentLeaveType: currentLeaveType ?? this.currentLeaveType
    );
  }

  @override
  List<Object?> get props => [
    createStatus,
    leaveDateType,
    leaveType,
    fromDateTime,
    toDateTime,
    fromDate,
    toDate,
    reason,
    leaveDays,
    listDateTypeLeaves,
    currentDateLeaveType,
    listTypeLeaves,
    currentLeaveType,
    listLeaveDays
  ];
}
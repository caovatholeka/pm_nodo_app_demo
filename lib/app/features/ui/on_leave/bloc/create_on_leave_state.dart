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

  CreateOnLeaveState({
    this.createStatus = LoadStatus.INITIAL,
    this.leaveDateType,
    this.leaveType,
    this.fromDateTime,
    this.toDateTime,
    this.fromDate,
    this.toDate,
    this.reason,
    this.leaveDays
  });

  CreateOnLeaveState copyWith({
    LoadStatus? createStatus,
    String? leaveDateType,
    String? leaveType,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    String? fromDate,
    String? toDate,
    String? reason,
    String? leaveDays
  }) {
    return CreateOnLeaveState(
      createStatus: createStatus ?? this.createStatus,
      leaveDateType: leaveDateType ?? this.leaveDateType,
      leaveType: leaveType ?? this.leaveType,
      fromDateTime: fromDateTime ?? this.fromDateTime,
      toDateTime: toDateTime ?? this.toDateTime,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      leaveDays: leaveDays ?? this.leaveDays
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
    leaveDays
  ];
}
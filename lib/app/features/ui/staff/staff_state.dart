part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  String? errMsg;
  String? errStatus;

  final List<EmployeeEntity>? listEmployees;

  StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.errMsg,
    this.errStatus,
    this.listEmployees,
  });

  StaffState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    String? errMsg,
    String? errStatus,
    List<EmployeeEntity>? listEmployees,
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      errMsg: errMsg ?? this.errMsg,
      errStatus: errStatus ?? this.errStatus,
      listEmployees: listEmployees ?? this.listEmployees,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    errMsg,
    errStatus,
    listEmployees,
  ];
}
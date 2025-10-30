part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  String? errMsg;
  String? errStatus;
  final List<EmployeeEntity>? listEmployees;
  final List<EmployeeEntity>?allEmployees;

  StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.errMsg,
    this.errStatus,
    this.listEmployees,
    this.allEmployees,
  });

  StaffState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    String? errMsg,
    String? errStatus,
    List<EmployeeEntity>? listEmployees,
    List<EmployeeEntity>? allEmployees
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      errMsg: errMsg ?? this.errMsg,
      errStatus: errStatus ?? this.errStatus,
      listEmployees: listEmployees ?? this.listEmployees,
      allEmployees: allEmployees ?? this.allEmployees
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